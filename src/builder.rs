//! Builds a nix derivation file (like a `shell.nix` file).
//!
//! It is a wrapper around `nix-build`.
//!
//! Note: this does not build the Nix expression as-is.
//! It instruments various nix builtins in a way that we
//! can parse additional information from the `nix-build`
//! `stderr`, like which source files are used by the evaluator.

use crate::cas::ContentAddressable;
use crate::nix::StorePath;
use crate::osstrlines;
use crate::{DrvFile, NixFile};
use crossbeam_channel as chan;
use regex::Regex;
use std::any::Any;
use std::ffi::{OsStr, OsString};
use std::io::BufReader;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::thread;

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
    pub gc_handle: crate::nix::GcRootTempDir,
    /// The realized store path
    pub path: StorePath,
}

struct InstantiateOutput {
    referenced_paths: Vec<PathBuf>,
    output: Option<RootedDrv>,
}

/// Wraps io::Error with a special case for the nix executable
#[derive(Debug)]
enum NixNotFoundError {
    /// one of the nix executables not found
    NixNotFound,
    Io(std::io::Error),
}

impl From<std::io::Error> for NixNotFoundError {
    fn from(e: std::io::Error) -> NixNotFoundError {
        NixNotFoundError::Io(e)
    }
}

fn instrumented_instantiation(
    tx: chan::Sender<OsString>,
    root_nix_file: &NixFile,
    cas: &ContentAddressable,
) -> Result<InstantiateOutput, NixNotFoundError> {
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

    let mut child = cmd.spawn().map_err(|e| match e.kind() {
        std::io::ErrorKind::NotFound => NixNotFoundError::NixNotFound,
        _ => NixNotFoundError::from(e),
    })?;

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
                .map(|line| {
                    line.map(|l| {
                        tx.send(l.clone()).expect("Receiver hung up!");
                        parse_evaluation_line(l)
                    })
                })
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
fn build(tx: chan::Sender<OsString>, drv_path: DrvFile) -> Result<BuildOutput, NixNotFoundError> {
    //let drv_path = s.path.clone();
    match crate::nix::CallOpts::file(drv_path.as_path())
        .set_stderr_sender(tx)
        .path()
    {
        Ok(realized) => Ok(BuildOutput {
            output: Some(RootedPath {
                gc_handle: realized.1,
                path: realized.0,
            }),
        }),
        Err(crate::nix::OnePathError::TooManyResults) => {
            panic!(
                "Too many results from building the instrumented, instantiated, shell environment."
            );
        }
        Err(crate::nix::OnePathError::Build(crate::nix::BuildError::NoResult)) => {
            panic!("No results from building the instrumented, instantiated, shell environment.");
        }
        Err(crate::nix::OnePathError::Build(crate::nix::BuildError::Io(e))) => {
            Err(NixNotFoundError::from(e))
        }
        Err(crate::nix::OnePathError::Build(crate::nix::BuildError::ExecutionFailed(_))) => {
            Ok(BuildOutput { output: None })
        }
        Err(crate::nix::OnePathError::Build(crate::nix::BuildError::NixNotFound)) => {
            Err(NixNotFoundError::NixNotFound)
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
pub fn run(
    tx: chan::Sender<OsString>,
    root_nix_file: &NixFile,
    cas: &ContentAddressable,
) -> Result<RunResult, Error> {
    let inst_info = instrumented_instantiation(tx.clone(), root_nix_file, cas)?;
    if let Some(inst_output) = inst_info.output {
        let buildoutput = build(tx, inst_output.path)?;

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

    /// Nix commands not on PATH
    NixNotFound,

    /// Failed to spawn a log processing thread
    ThreadFailure(std::boxed::Box<(dyn std::any::Any + std::marker::Send + 'static)>),
}
impl From<std::io::Error> for Error {
    fn from(e: std::io::Error) -> Error {
        Error::Instantiate(e)
    }
}

impl From<NixNotFoundError> for Error {
    fn from(e: NixNotFoundError) -> Error {
        match e {
            NixNotFoundError::Io(e) => Error::Instantiate(e),
            NixNotFoundError::NixNotFound => Error::NixNotFound,
        }
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
    use crate::cas::ContentAddressable;
    use std::ffi::OsString;
    use std::os::unix::ffi::OsStrExt;
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
        let (tx, rx) = chan::unbounded();
        let info = run(
            tx,
            &crate::NixFile::from(cas.file_from_string(&nix_drv)?),
            &cas,
        )
        .unwrap();
        let stderr = rx.iter().collect::<Vec<OsString>>();
        println!("stderr:");
        for line in &stderr {
            println!("{:?}", line)
        }

        match info.status {
            RunStatus::Complete(_) => {}
            _ => {
                panic!("could not run() the drv:\n{:?}", info,);
            }
        }

        let expect: &[u8] = b"\"\xAB\xBC\xCD\xDE\xDE\xEF\"";
        assert!(
            stderr.iter().any(|line| {
                line.as_bytes()
                    .windows(expect.len())
                    .any(|bytes| bytes == expect)
            }),
            "Couldn’t find the byte output in the realize stderr",
        );
        Ok(())
    }

    /// If the build fails, we shouldn’t crash in the process.
    #[test]
    fn gracefully_handle_failing_build() -> std::io::Result<()> {
        let tmp = tempfile::tempdir()?;
        let cas = ContentAddressable::new(tmp.path().to_owned())?;

        let d = crate::NixFile::from(cas.file_from_string(&drv(
            "shell",
            &format!("dep = {};", drv("dep", r##"args = [ "-c" "exit 1" ];"##)),
        ))?);

        let (tx, _rx) = chan::unbounded();
        run(tx, &d, &cas).expect("build can fail, but must not panic");
        Ok(())
    }

    // TODO: builtins.fetchTarball and the like? What happens with those?
    // Are they directories and if yes, should we watch them?
    /// The paths that are returned by the nix-instantiate call
    /// must not contain directories, otherwise the watcher will
    /// watch those recursively, which leads to a lot of wasted resources
    /// and often exhausts the amount of available file handles
    /// (especially on macOS).
    #[test]
    fn no_unnecessary_files_or_directories_watched() -> std::io::Result<()> {
        let root_tmp = tempfile::tempdir()?;
        let cas_tmp = tempfile::tempdir()?;
        let root = root_tmp.path();
        let shell = root.join("shell.nix");
        std::fs::write(
            &shell,
            drv(
                "shell",
                r##"
# The `foo/default.nix` is implicitely imported
# (we only want to watch that one, not the whole directory)
foo = import ./foo;
# `dir` is imported as source directory (no `import`).
# We *do* want to watch this directory, because we need to react
# when the user updates it.
dir-as-source = ./dir;
"##,
            ),
        )?;

        // ./foo
        // ./foo/default.nix
        // ./foo/bar <- should not be watched
        // ./foo/baz <- should be watched
        // ./dir <- should be watched, because imported as source
        let foo = root.join("foo");
        std::fs::create_dir(&foo)?;
        let dir = root.join("dir");
        std::fs::create_dir(&dir)?;
        let foo_default = &foo.join("default.nix");
        std::fs::write(&foo_default, "import ./baz")?;
        let foo_bar = &foo.join("bar");
        std::fs::write(&foo_bar, "This file should not be watched")?;
        let foo_baz = &foo.join("baz");
        std::fs::write(&foo_baz, "\"This file should be watched\"")?;

        let cas = ContentAddressable::new(cas_tmp.path().join("cas"))?;

        let (tx, rx) = chan::unbounded();
        let inst_info = instrumented_instantiation(tx, &NixFile::from(shell), &cas).unwrap();
        let ends_with = |end| inst_info.referenced_paths.iter().any(|p| p.ends_with(end));
        assert!(
            ends_with("foo/default.nix"),
            "foo/default.nix should be watched!"
        );
        assert!(!ends_with("foo/bar"), "foo/bar should not be watched!");
        assert!(ends_with("foo/baz"), "foo/baz should be watched!");
        assert!(ends_with("dir"), "dir should be watched!");
        assert!(
            !ends_with("foo"),
            "No imported directories must exist in watched paths: {:#?}",
            inst_info.referenced_paths
        );
        // unused
        drop(rx);

        Ok(())
    }
}
