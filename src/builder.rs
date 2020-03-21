//! Builds a nix derivation file (like a `shell.nix` file).
//!
//! It is a wrapper around `nix-build`.
//!
//! Note: this does not build the Nix expression as-is.
//! It instruments various nix builtins in a way that we
//! can parse additional information from the `nix-build`
//! `stderr`, like which source files are used by the evaluator.

use crate::cas::ContentAddressable;
use crate::error::BuildError;
use crate::nix::StorePath;
use crate::osstrlines;
use crate::{DrvFile, NixFile};
use regex::Regex;
use slog_scope::debug;
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

/// A path that was accessed during instantiation and should be watched
/// for changes.
#[derive(Debug)]
pub enum ReferencedPath {
    /// Should watch the whole directory (if the path is a directory).
    Recursive(PathBuf),
    /// Just watch path that was accessed.
    NotRecursive(PathBuf),
}

struct InstantiateOutput {
    referenced_paths: Vec<ReferencedPath>,
    output: RootedDrv,
}

fn instrumented_instantiation(
    nix_file: &NixFile,
    cas: &ContentAddressable,
) -> Result<InstantiateOutput, BuildError> {
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
        OsStr::new("runtimeClosure"),
        OsStr::new(crate::RUN_TIME_CLOSURE),
        // the source file
        OsStr::new("--argstr"),
    ]);
    match nix_file {
        NixFile::Shell(shell) => cmd.args(&[OsStr::new("shellSrc"), shell.as_os_str()]),
        NixFile::Services(services) => cmd.args(&[OsStr::new("servicesSrc"), services.as_os_str()]),
    };
    cmd.args(&[
        // instrumented by `./logged-evaluation.nix`
        OsStr::new("--"),
        &logged_evaluation_nix.as_os_str(),
    ])
    .stdin(Stdio::null())
    .stdout(Stdio::piped())
    .stderr(Stdio::piped());

    debug!("nix-instantiate"; "command" => ?cmd);

    let mut child = cmd.spawn().map_err(|e| match e.kind() {
        std::io::ErrorKind::NotFound => BuildError::spawn(&cmd, e),
        _ => BuildError::io(e),
    })?;

    let stdout = child
        .stdout
        .take()
        .expect("we must be able to access the stdout of nix-instantiate");
    let stderr = child
        .stderr
        .take()
        .expect("we must be able to access the stderr of nix-instantiate");

    let stderr_results = thread::spawn(move || {
        osstrlines::Lines::from(BufReader::new(stderr))
            .map(|line| line.map(parse_evaluation_line))
            .collect::<Result<Vec<LogDatum>, _>>()
    });

    let build_products = thread::spawn(move || {
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
    let (paths, log_lines): (Vec<ReferencedPath>, Vec<OsString>) =
        results
            .into_iter()
            .fold((vec![], vec![]), |(mut paths, mut log_lines), result| {
                match result {
                    LogDatum::CopiedSource(src) => {
                        // For these files we want to watch the whole directorie tree
                        paths.push(ReferencedPath::Recursive(src));
                    }
                    LogDatum::ReadFileOrDir(src) => {
                        // Reading the directory should not cause a recursive watch
                        paths.push(ReferencedPath::NotRecursive(src));
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
                        paths.push(ReferencedPath::NotRecursive(src));
                    }
                    LogDatum::Text(line) => log_lines.push(OsString::from(line)),
                    LogDatum::NonUtf(line) => log_lines.push(line),
                };

                (paths, log_lines)
            });

    if !exec_result.success() {
        return Err(BuildError::exit(&cmd, exec_result, log_lines));
    }

    assert!(
        build_products.len() == 1,
        "got more or less than one build product from logged_evaluation.nix: {:#?}",
        build_products
    );
    let shell_gc_root = build_products.pop().unwrap();

    Ok(InstantiateOutput {
        referenced_paths: paths,
        output: RootedDrv {
            _gc_handle: GcRootTempDir(gc_root_dir),
            path: shell_gc_root,
        },
    })
}

struct BuildOutput {
    output: RootedPath,
}

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information, which is valuable even if the build fails.
fn build(drv_path: DrvFile) -> Result<BuildOutput, BuildError> {
    let (path, gc_handle) = crate::nix::CallOpts::file(drv_path.as_path()).path()?;
    Ok(BuildOutput {
        output: RootedPath { gc_handle, path },
    })
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
    pub referenced_paths: Vec<ReferencedPath>,
    /// The status of the build attempt
    pub result: RootedPath,
}

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information,
/// which is valuable even if the build fails.
pub fn run(root_nix_file: &NixFile, cas: &ContentAddressable) -> Result<RunResult, BuildError> {
    let inst_info = instrumented_instantiation(root_nix_file, cas)?;
    let buildoutput = build(inst_info.output.path)?;
    Ok(RunResult {
        referenced_paths: inst_info.referenced_paths,
        result: buildoutput.output,
    })
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
    lazy_static::lazy_static! {
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
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OutputPaths<T> {
    /// Shell path modified to work as a gc root
    pub shell_gc_root: T,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cas::ContentAddressable;
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
        run(
            &crate::NixFile::Shell(cas.file_from_string(&nix_drv)?),
            &cas,
        )
        .expect("should not crash!");
        Ok(())
    }

    /// If the build fails, we shouldn’t crash in the process.
    #[test]
    fn gracefully_handle_failing_build() -> std::io::Result<()> {
        let tmp = tempfile::tempdir()?;
        let cas = ContentAddressable::new(tmp.path().to_owned())?;

        let d = crate::NixFile::Shell(cas.file_from_string(&drv(
            "shell",
            &format!("dep = {};", drv("dep", r##"args = [ "-c" "exit 1" ];"##)),
        ))?);

        if let Err(BuildError::Exit { .. }) = run(&d, &cas) {
        } else {
            assert!(
                false,
                "builder::run should have failed with BuildError::Exit"
            );
        }
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

        let inst_info = instrumented_instantiation(&NixFile::Shell(shell), &cas).unwrap();
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
        Ok(())
    }

    #[test]
    fn services_builds_json() -> std::io::Result<()> {
        let root_tmp = tempfile::tempdir()?;
        let cas_tmp = tempfile::tempdir()?;
        let root = root_tmp.path();
        let services = root.join("services.nix");
        std::fs::write(
            &services,
            r##"
let
  program1 = import ./program1;
  program2 = import ./program2/custom.nix;
in
[ { name = "service1"; program = "${program1}"; args = [ "--fast" ]; }
  { name = "service2"; program = "${program2}"; args = [ "--faster" ]; } ]
"##,
        )?;

        let program1 = root.join("program1");
        std::fs::create_dir(&program1)?;
        let program1_default = &program1.join("default.nix");
        std::fs::write(&program1_default, "\"program1_path\"")?;

        let program2 = root.join("program2");
        std::fs::create_dir(&program2)?;
        let program2_custom = &program2.join("custom.nix");
        std::fs::write(&program2_custom, "\"program2_path\"")?;

        let cas = ContentAddressable::new(cas_tmp.path().join("cas"))?;

        let RunResult {
            result: RootedPath { path, .. },
            referenced_paths: _,
        } = run(&NixFile::Services(services), &cas).unwrap();

        let path = path.as_path();

        let services_json = path.join("services.json");
        assert!(services_json.is_file(), "services.json must be a file");

        let mut writer: Vec<u8> = Vec::new();
        std::io::copy(
            &mut std::fs::File::open(services_json).unwrap(),
            &mut writer,
        )
        .unwrap();
        assert_eq!(
            r##"[{"args":["--fast"],"name":"service1","program":"program1_path"},{"args":["--faster"],"name":"service2","program":"program2_path"}]"##,
            String::from_utf8(writer).unwrap().trim()
        );
        Ok(())
    }

    #[test]
    fn services_dependencies_watched() -> std::io::Result<()> {
        let root_tmp = tempfile::tempdir()?;
        let cas_tmp = tempfile::tempdir()?;
        let root = root_tmp.path();
        let services = root.join("services.nix");
        std::fs::write(
            &services,
            r##"
let
  program1 = import ./program1;
  program2 = import ./program2/custom.nix;
in
[ { name = "service1"; program = "${program1}"; args = [ "--fast" ]; }
  { name = "service2"; program = "${program2}"; args = [ "--faster" ]; } ]
"##,
        )?;

        let program1 = root.join("program1");
        std::fs::create_dir(&program1)?;
        let program1_default = &program1.join("default.nix");
        std::fs::write(&program1_default, "\"program1_path\"")?;

        let program2 = root.join("program2");
        std::fs::create_dir(&program2)?;
        let program2_custom = &program2.join("custom.nix");
        std::fs::write(&program2_custom, "\"program2_path\"")?;

        let cas = ContentAddressable::new(cas_tmp.path().join("cas"))?;

        let inst_info = instrumented_instantiation(&NixFile::Services(services), &cas).unwrap();

        let ends_with = |end| inst_info.referenced_paths.iter().any(|p| p.ends_with(end));
        assert!(
            ends_with("program1/default.nix"),
            "program1/default.nix should be watched!"
        );
        assert!(
            ends_with("program2/custom.nix"),
            "program2/custom.nix should be watched!"
        );
        Ok(())
    }
}
