//! Builds a nix derivation file (like a `shell.nix` file).
//!
//! It is a wrapper around `nix-build`.
//!
//! Note: this does not build the Nix expression as-is.
//! It instruments various nix builtins in a way that we
//! can parse additional information from the `nix-build`
//! `stderr`, like which source files are used by the evaluator.

use cas::ContentAddressable;
use nix::StorePath;
use osstrlines;
use regex::Regex;
use std::any::Any;
use std::ffi::{OsStr, OsString};
use std::io::BufReader;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::thread;
use {DrvFile, NixFile};

struct RootedDrv {
    _gc_handle: GcRootTempDir,
    path: DrvFile,
}


/// Represents a path which is temporarily rooted in a temporary directory.
/// Users are required to keep the gc_handle value alive for as long as
/// StorePath is alive, _or_ re-root the StorePath using project::Roots
/// before dropping gc_handle.
#[derive(Debug)]
pub struct RootedPath {
    /// The handle to a temporary directory keeping `.path` alive.
    pub gc_handle: ::nix::GcRootTempDir,
    /// The realized store path
    pub path: StorePath,
}

struct InstantiateOutput {
    referenced_paths: Vec<PathBuf>,
    output: Option<RootedDrv>,
}

fn instrumented_instantiation(
    root_nix_file: &NixFile,
    cas: &ContentAddressable,
) -> Result<InstantiateOutput, std::io::Error> {
    // We're looking for log lines matching:
    //
    //     copied source '...' -> '/nix/store/...'
    //     evaluating file '...'
    //
    // to determine which files we should setup watches on.
    // Increasing verbosity by two levels via `-vv` satisfies that.

    let mut cmd = Command::new("nix-instantiate");

    let logged_evaluation_nix = cas.file_from_string(include_str!("./logged-evaluation.nix"))?;

    // TODO: see ::nix::CallOpts::paths for the problem with this
    let gc_root_dir = tempfile::TempDir::new()?;

    cmd.args(&[
        // verbose mode prints the files we track
        OsStr::new("-vv"),
        // we add a temporary indirect GC root
        OsStr::new("--add-root"),
        gc_root_dir.path().join("result").as_os_str(),
        OsStr::new("--indirect"),
        OsStr::new("--argstr"),
        // runtime nix paths to needed dependencies that come with lorri
        OsStr::new("runTimeClosure"),
        OsStr::new(crate::RUN_TIME_CLOSURE),
        // the source file
        OsStr::new("--argstr"),
        OsStr::new("src"),
        root_nix_file.as_os_str(),
        // instrumented by `./logged-evaluation.nix`
        OsStr::new("--"),
        &logged_evaluation_nix.as_os_str(),
    ])
    .stdin(Stdio::null())
    .stdout(Stdio::piped())
    .stderr(Stdio::piped());

    debug!("$ {:?}", cmd);

    let mut child = cmd.spawn()?;

    let stdout = child
        .stdout
        .take()
        .expect("we must be able to access the stdout of nix-build");
    let stderr = child
        .stderr
        .take()
        .expect("we must be able to access the stderr of nix-build");

    let stderr_results: thread::JoinHandle<std::io::Result<Vec<LogDatum>>> =
        thread::spawn(move || {
            osstrlines::Lines::from(BufReader::new(stderr))
                .map(|line| line.map(parse_evaluation_line))
                .collect::<Result<Vec<LogDatum>, _>>()
        });

    let build_products: thread::JoinHandle<std::io::Result<Vec<DrvFile>>> =
        thread::spawn(move || {
            osstrlines::Lines::from(BufReader::new(stdout))
                .map(|line| line.map(|os_string| DrvFile::from(PathBuf::from(os_string))))
                .collect::<Result<Vec<DrvFile>, _>>()
        });

    let (exec_result, mut build_products, results) = (
        child.wait()?,
        build_products
            .join()
            .expect("Failed to join stdout processing thread")?,
        stderr_results
            .join()
            .expect("Failed to join stderr processing thread")?,
    );

    // TODO: this can move entirely into the stderr thread,
    // meaning we don’t have to keep the outputs in memory (fold directly)

    // iterate over all lines, parsing out the ones we are interested in
    let (paths, _log_lines): (Vec<PathBuf>, Vec<OsString>) =
        results
            .into_iter()
            .fold((vec![], vec![]), |(mut paths, mut log_lines), result| {
                match result {
                    LogDatum::CopiedSource(src) | LogDatum::ReadFileOrDir(src) => {
                        paths.push(src);
                    }
                    LogDatum::NixSourceFile(mut src) => {
                        // We need to emulate nix’s `default.nix` mechanism here.
                        // That is, if the user uses something like
                        // `import ./foo`
                        // and `foo` is a directory, nix will actually import
                        // `./foo/default.nix`
                        // but still print `./foo`.
                        // Since this is the only time directories are printed,
                        // we can just manually re-implement that behavior.
                        if src.is_dir() {
                            src.push("default.nix");
                        }
                        paths.push(src);
                    }
                    LogDatum::Text(line) => log_lines.push(OsString::from(line)),
                    LogDatum::NonUtf(line) => log_lines.push(line),
                };

                (paths, log_lines)
            });

    if !exec_result.success() {
        return Ok(InstantiateOutput {
            referenced_paths: paths,
            output: None,
        });
    }

    assert!(
        build_products.len() == 1,
        "got more or less than one build product from logged_evaluation.nix: {:#?}",
        build_products
    );
    let shell_gc_root = build_products.pop().unwrap();

    Ok(InstantiateOutput {
        referenced_paths: paths,
        output: Some(RootedDrv {
            _gc_handle: GcRootTempDir(gc_root_dir),
            path: shell_gc_root,
        }),
    })
}

struct BuildOutput {
    output: Option<RootedPath>,
}

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information,
/// which is valuable even if the build fails.
fn build(drv_path: DrvFile) -> Result<BuildOutput, std::io::Error> {
    //let drv_path = s.path.clone();
    match ::nix::CallOpts::file(drv_path.as_path()).path() {
        Ok(realized) => Ok(BuildOutput {
            output: Some(RootedPath {
                gc_handle: realized.1,
                path: realized.0,
            }),
        }),
        Err(::nix::OnePathError::TooManyResults) => {
            panic!(
                "Too many results from building the instrumented, instantiated, shell environment."
            );
        }
        Err(::nix::OnePathError::Build(::nix::BuildError::NoResult)) => {
            panic!("No results from building the instrumented, instantiated, shell environment.");
        }
        Err(::nix::OnePathError::Build(::nix::BuildError::Io(e))) => Err(e),
        Err(::nix::OnePathError::Build(::nix::BuildError::ExecutionFailed(_))) => {
            Ok(BuildOutput { output: None })
        }
    }
}

/// Opaque type to keep a temporary GC root directory alive.
/// Once it is dropped, the GC root is removed.
/// Copied from `nix`, because the type should stay opaque.
#[derive(Debug)]
struct GcRootTempDir(tempfile::TempDir);

/// The result of a single instantiation and build.
#[derive(Debug)]
pub struct RunResult {
    /// All the paths identified during the instantiation
    pub referenced_paths: Vec<PathBuf>,
    /// The status of the build attempt
    pub status: RunStatus,
}

/// How far along we got in the instantiate then realize.
#[derive(Debug)]
pub enum RunStatus {
    /// The instantiation was attempted, but failed.
    FailedAtInstantiation,
    /// The instantiation succeded. The realize was attempted, but failed.
    FailedAtRealize,
    /// The instantiation and realize succeeded and yielded a result path.
    Complete(RootedPath),
}

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information,
/// which is valuable even if the build fails.
pub fn run(root_nix_file: &NixFile, cas: &ContentAddressable) -> Result<RunResult, Error> {
    let inst_info = instrumented_instantiation(root_nix_file, cas)?;
    if let Some(inst_output) = inst_info.output {
        let buildoutput = build(inst_output.path)?;

        if let Some(build_output) = buildoutput.output {
            Ok(RunResult {
                referenced_paths: inst_info.referenced_paths,
                status: RunStatus::Complete(build_output),
            })
        } else {
            Ok(RunResult {
                referenced_paths: inst_info.referenced_paths,
                status: RunStatus::FailedAtRealize,
            })
        }
    } else {
        Ok(RunResult {
            referenced_paths: inst_info.referenced_paths,
            status: RunStatus::FailedAtInstantiation,
        })
    }
}

/// Classifies the output of nix-instantiate -vv.
#[derive(Debug, PartialEq)]
enum LogDatum {
    /// Nix source file (which should be tracked)
    NixSourceFile(PathBuf),
    /// A file/directory copied verbatim to the nix store
    CopiedSource(PathBuf),
    /// A `builtins.readFile` or `builtins.readDir` invocation (at eval time)
    ReadFileOrDir(PathBuf),
    /// Arbitrary text (which we couldn’t otherwise classify)
    Text(String),
    /// Text which we coudn’t decode from UTF-8
    NonUtf(OsString),
}

/// Examine a line of output and extract interesting log items in to
/// structured data.
fn parse_evaluation_line<T>(line: T) -> LogDatum
where
    T: AsRef<OsStr>,
{
    lazy_static! {
        // These are the .nix files that are opened for evaluation.
        static ref EVAL_FILE: Regex =
            Regex::new("^evaluating file '(?P<source>.*)'$").expect("invalid regex!");
        // When you reference a source file, nix copies it to the store and prints this.
        // This the same is true for directories (e.g. `foo = ./abc` in a derivation).
        static ref COPIED_SOURCE: Regex =
            Regex::new("^copied source '(?P<source>.*)' -> '(?:.*)'$").expect("invalid regex!");
        // These are printed for `builtins.readFile` and `builtins.readDir`,
        // by our instrumentation in `./logged-evaluation.nix`.
        static ref LORRI_READ: Regex =
            Regex::new("^trace: lorri read: '(?P<source>.*)'$").expect("invalid regex!");
    }

    // see the regexes above for explanations of the nix outputs
    match line.as_ref().to_str() {
        // If we can’t decode the output line to an UTF-8 string,
        // we cannot match against regexes, so just pass it through.
        None => LogDatum::NonUtf(line.as_ref().to_owned()),
        Some(linestr) => {
            // Lines about evaluating a file are much more common, so looking
            // for them first will reduce comparisons.
            if let Some(matches) = EVAL_FILE.captures(&linestr) {
                LogDatum::NixSourceFile(PathBuf::from(&matches["source"]))
            } else if let Some(matches) = COPIED_SOURCE.captures(&linestr) {
                LogDatum::CopiedSource(PathBuf::from(&matches["source"]))
            // TODO: parse files and dirs into different LogInfo cases
            // to make sure we only watch directories if they were builtins.readDir’ed
            } else if let Some(matches) = LORRI_READ.captures(&linestr) {
                LogDatum::ReadFileOrDir(PathBuf::from(&matches["source"]))
            } else {
                LogDatum::Text(linestr.to_owned())
            }
        }
    }
}

/// The results of an individual instantiation/build.
/// Even if the exit code is not 0, there is still
/// valuable information in the output, like new paths
/// to watch.
#[derive(Debug)]
pub enum Info<T, TempDir> {
    /// Nix ran successfully.
    Success(Success<T, TempDir>),
    /// Nix returned a failing status code.
    Failure(Failure),
}

/// A successful Nix run.
#[derive(Debug)]
pub struct Success<T, TempDir> {
    /// See `OutputPaths`
    // TODO: move back to `OutputPaths<T>`
    pub output_paths: OutputPaths<T>,

    /// Handle that keeps the temporary GC root directory around
    pub gc_root_temp_dir: TempDir,

    // TODO: rename to `sources` (it’s the input sources we have to watch)
    /// A list of paths examined during the evaluation
    pub paths: Vec<PathBuf>,

    // INFO: only used in test so far
    /// A list of stderr log lines
    pub log_lines: Vec<OsString>,
}

/// A failing Nix run.
#[derive(Debug)]
pub struct Failure {
    /// The error status code
    exec_result: std::process::ExitStatus,

    /// A list of stderr log lines
    pub log_lines: Vec<OsString>,
}

/// Output paths generated by `logged-evaluation.nix`
#[derive(Debug, Clone)]
pub struct OutputPaths<T> {
    /// Shell path modified to work as a gc root
    pub shell_gc_root: T,
}

/// Possible errors from an individual evaluation
#[derive(Debug)]
pub enum Error {
    /// Executing nix-instantiate failed
    Instantiate(std::io::Error),

    /// Executing nix-build failed
    Build(::nix::OnePathError),

    /// Failed to spawn a log processing thread
    ThreadFailure(std::boxed::Box<(dyn std::any::Any + std::marker::Send + 'static)>),
}
impl From<std::io::Error> for Error {
    fn from(e: std::io::Error) -> Error {
        Error::Instantiate(e)
    }
}

impl From<Box<dyn Any + Send + 'static>> for Error {
    fn from(e: std::boxed::Box<(dyn std::any::Any + std::marker::Send + 'static)>) -> Error {
        Error::ThreadFailure(e)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use cas::ContentAddressable;
    use std::ffi::OsString;
    use std::path::PathBuf;

    /// Parsing of `LogDatum`.
    #[test]
    fn evaluation_line_to_log_datum() {
        assert_eq!(
            parse_evaluation_line("evaluating file '/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/lib/systems/for-meta.nix'"),
            LogDatum::NixSourceFile(PathBuf::from("/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/lib/systems/for-meta.nix"))
        );

        assert_eq!(
            parse_evaluation_line("copied source '/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/pkgs/stdenv/generic/default-builder.sh' -> '/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh'"),
            LogDatum::CopiedSource(PathBuf::from("/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/pkgs/stdenv/generic/default-builder.sh"))
        );

        assert_eq!(
            parse_evaluation_line(
                "trace: lorri read: '/home/grahamc/projects/grahamc/lorri/nix/nixpkgs.json'"
            ),
            LogDatum::ReadFileOrDir(PathBuf::from(
                "/home/grahamc/projects/grahamc/lorri/nix/nixpkgs.json"
            ))
        );

        assert_eq!(
            parse_evaluation_line(
                "downloading 'https://static.rust-lang.org/dist/channel-rust-stable.toml'..."
            ),
            LogDatum::Text(String::from(
                "downloading 'https://static.rust-lang.org/dist/channel-rust-stable.toml'..."
            ))
        );
    }

    /// Create a locally built base derivation expression.
    /// `args` is just interpolated into the derivation fields.
    fn drv(name: &str, args: &str) -> String {
        format!(
            r##"
derivation {{
  name = "{}";
  builder = "/bin/sh";
  allowSubstitutes = false;
  preferLocalBuild = true;
  system = builtins.currentSystem;
  # this is to make nix rebuild for every test
  random = builtins.currentTime;
  {}
}}"##,
            name, args
        )
    }

    /// Some nix builds can output non-UTF-8 encoded text
    /// (arbitrary binary output). We should not crash in that case.
    #[test]
    fn non_utf8_nix_output() -> std::io::Result<()> {
        let tmp = tempfile::tempdir()?;
        let cas = ContentAddressable::new(tmp.path().to_owned())?;

        let inner_drv = drv(
            "dep",
            r##"
args = [
    "-c"
    ''
    # non-utf8 sequence to stdout (which is nix stderr)
    printf '"\xab\xbc\xcd\xde\xde\xef"'
    echo > $out
    ''
];"##,
        );

        let nix_drv = format!(
            r##"
let dep = {};
in {}
"##,
            inner_drv,
            drv("shell", "inherit dep;")
        );

        print!("{}", nix_drv);

        // build, because instantiate doesn’t return the build output (obviously …)
        let info = run(&::NixFile::from(cas.file_from_string(&nix_drv)?), &cas).unwrap();
        match info.status {
            RunStatus::Complete(_) => {}
            _ => panic!("could not run() the drv:\n{:?}", info),
        }

        // next, check the build log for the bytes;
        // we have to query nix log because we don’t store the
        // output of nix realisation anywhere (only instantiation);
        // fixing that is a TODO
        let expect: &[u8] = b"\"\xAB\xBC\xCD\xDE\xDE\xEF\"";
        // get the store path of our inner derivation, so that we
        // can actually get the log output for that
        let (store_path, gc_root) = ::nix::CallOpts::file(&cas.file_from_string(&inner_drv)?)
            .path()
            .unwrap();
        let mut cmd = std::process::Command::new("nix-store");
        let cmd = cmd.arg("--read-log").arg(&store_path.as_path());
        print!("{:?}", cmd);
        let log_lines = cmd.output()?;
        assert!(log_lines.status.success(), "{:?}", log_lines);
        // The stdout of nix-store --read-log should contain our bytes
        assert!(
            log_lines
                .stdout
                .windows(expect.len())
                .any(|bytes| bytes == expect),
            "{:?}",
            String::from_utf8_lossy(&log_lines.stderr)
        );
        drop(gc_root);
        Ok(())
    }

    /// If the build fails, we shouldn’t crash in the process.
    #[test]
    fn gracefully_handle_failing_build() -> std::io::Result<()> {
        let tmp = tempfile::tempdir()?;
        let cas = ContentAddressable::new(tmp.path().to_owned())?;

        let d = ::NixFile::from(cas.file_from_string(&drv(
            "shell",
            &format!("dep = {};", drv("dep", r##"args = [ "-c" "exit 1" ];"##)),
        ))?);

        run(&d, &cas).expect("build can fail, but must not panic");
        Ok(())
    }

}
