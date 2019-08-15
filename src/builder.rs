//! Builds a nix derivation file (like a `shell.nix` file).
//!
//! It is a wrapper around `nix-build`.
//!
//! Note: this does not build the Nix expression as-is.
//! It instruments various nix builtins in a way that we
//! can parse additional information from the `nix-build`
//! `stderr`, like which source files are used by the evaluator.

use cas::ContentAddressable;
use osstrlines;
use regex::Regex;
use std::any::Any;
use std::collections::HashMap;
use std::ffi::{OsStr, OsString};
use std::io::BufReader;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::thread;
use NixFile;

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information,
/// which is valuable even if the build fails.
pub fn run(root_nix_file: &NixFile, cas: &ContentAddressable) -> Result<Info, Error> {
    // We're looking for log lines matching:
    //
    //     copied source '...' -> '/nix/store/...'
    //     evaluating file '...'
    //
    // to determine which files we should setup watches on.
    // Increasing verbosity by two levels via `-vv` satisfies that.

    let mut cmd = Command::new("nix-build");

    let logged_evaluation_nix = cas.file_from_string(include_str!("./logged-evaluation.nix"))?;

    cmd.args(&[
        OsStr::new("-vv"),
        OsStr::new("--no-out-link"),
        OsStr::new("--argstr"),
        OsStr::new("runTimeClosure"),
        OsStr::new(crate::RUN_TIME_CLOSURE),
        OsStr::new("--argstr"),
        OsStr::new("src"),
        root_nix_file.as_os_str(),
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

    let produced_drvs: thread::JoinHandle<std::io::Result<Vec<PathBuf>>> =
        thread::spawn(move || {
            osstrlines::Lines::from(BufReader::new(stdout))
                .map(|line| line.map(PathBuf::from))
                .collect::<Result<Vec<PathBuf>, _>>()
        });

    let (exec_result, produced_drvs, results) = (
        child.wait()?,
        produced_drvs.join()??,
        stderr_results.join()??,
    );

    let (paths, named_drvs, log_lines): (Vec<PathBuf>, HashMap<String, PathBuf>, Vec<OsString>) =
        results.into_iter().fold(
            (vec![], HashMap::new(), vec![]),
            |(mut paths, mut named_drvs, mut log_lines), result| {
                match result {
                    LogDatum::Source(src) => {
                        paths.push(src);
                    }
                    LogDatum::AttrDrv(name, drv) => {
                        named_drvs.insert(name, drv);
                    }
                    LogDatum::Text(line) => log_lines.push(line),
                };

                (paths, named_drvs, log_lines)
            },
        );
    Ok(Info {
        exec_result,
        drvs: produced_drvs,
        named_drvs,
        paths,
        log_lines,
    })
}

#[derive(Debug, PartialEq)]
enum LogDatum {
    Source(PathBuf),
    AttrDrv(String, PathBuf),
    Text(OsString),
}

/// Examine a line of output and extract interesting log items in to
/// structured data.
fn parse_evaluation_line<T>(line: T) -> LogDatum
where
    T: AsRef<OsStr>,
{
    lazy_static! {
        static ref EVAL_FILE: Regex =
            Regex::new("^evaluating file '(?P<source>.*)'$").expect("invalid regex!");
        static ref COPIED_SOURCE: Regex =
            Regex::new("^copied source '(?P<source>.*)' -> '(?:.*)'$").expect("invalid regex!");
        static ref LORRI_READ: Regex =
            Regex::new("^trace: lorri read: '(?P<source>.*)'$").expect("invalid regex!");
        static ref LORRI_ATTR_DRV: Regex =
            Regex::new("^trace: lorri attribute: '(?P<attribute>.*)' -> '(?P<drv>/nix/store/.*)'$")
                .expect("invalid regex!");
    }

    match line.as_ref().to_str() {
        // If we can’t decode the output line to an UTF-8 string,
        // we cannot match against regexes, so just pass it through.
        None => LogDatum::Text(line.as_ref().to_owned()),
        Some(linestr) => {
            // Lines about evaluating a file are much more common, so looking
            // for them first will reduce comparisons.
            if let Some(matches) = EVAL_FILE.captures(&linestr) {
                LogDatum::Source(PathBuf::from(&matches["source"]))
            } else if let Some(matches) = COPIED_SOURCE.captures(&linestr) {
                LogDatum::Source(PathBuf::from(&matches["source"]))
            } else if let Some(matches) = LORRI_READ.captures(&linestr) {
                LogDatum::Source(PathBuf::from(&matches["source"]))
            } else if let Some(matches) = LORRI_ATTR_DRV.captures(&linestr) {
                LogDatum::AttrDrv(
                    String::from(&matches["attribute"]),
                    PathBuf::from(&matches["drv"]),
                )
            } else {
                LogDatum::Text(line.as_ref().to_owned())
            }
        }
    }
}

/// The results of an individual build.
/// Even if the exit code is not 0, there is still
/// valuable information in the output, like new paths
/// to watch.
#[derive(Debug)]
pub struct Info {
    /// The result of executing Nix
    pub exec_result: std::process::ExitStatus,

    // TODO: what?
    // are those actual drv files?
    /// All the attributes in the default expression which belong to
    /// attributes.
    pub named_drvs: HashMap<String, PathBuf>,

    /// A list of the evaluation's result derivations
    pub drvs: Vec<PathBuf>,

    /// A list of paths examined during the evaluation
    pub paths: Vec<PathBuf>,

    /// A list of stderr log lines
    pub log_lines: Vec<OsString>,
}

/// Possible errors from an individual evaluation
#[derive(Debug)]
pub enum Error {
    /// IO error executing nix-instantiate
    Io(std::io::Error),

    /// Failed to spawn a log processing thread
    ThreadFailure(std::boxed::Box<(dyn std::any::Any + std::marker::Send + 'static)>),
}
impl From<std::io::Error> for Error {
    fn from(e: std::io::Error) -> Error {
        Error::Io(e)
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

    #[test]
    fn test_evaluation_line_to_path_evaluation() {
        assert_eq!(
            parse_evaluation_line("evaluating file '/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/lib/systems/for-meta.nix'"),
            LogDatum::Source(PathBuf::from("/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/lib/systems/for-meta.nix"))
        );

        assert_eq!(
            parse_evaluation_line("copied source '/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/pkgs/stdenv/generic/default-builder.sh' -> '/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh'"),
            LogDatum::Source(PathBuf::from("/nix/store/zqxha3ax0w771jf25qdblakka83660gr-source/pkgs/stdenv/generic/default-builder.sh"))
        );

        assert_eq!(
            parse_evaluation_line(
                "trace: lorri read: '/home/grahamc/projects/grahamc/lorri/nix/nixpkgs.json'"
            ),
            LogDatum::Source(PathBuf::from(
                "/home/grahamc/projects/grahamc/lorri/nix/nixpkgs.json"
            ))
        );

        assert_eq!(
            parse_evaluation_line("trace: lorri attribute: 'shell' -> '/nix/store/q3ngidzvincycjjvlilf1z6vj1w4wnas-lorri.drv'"),
            LogDatum::AttrDrv(String::from("shell"), PathBuf::from("/nix/store/q3ngidzvincycjjvlilf1z6vj1w4wnas-lorri.drv"))
        );

        assert_eq!(
            parse_evaluation_line(
                "downloading 'https://static.rust-lang.org/dist/channel-rust-stable.toml'..."
            ),
            LogDatum::Text(OsString::from(
                "downloading 'https://static.rust-lang.org/dist/channel-rust-stable.toml'..."
            ))
        );
    }

    #[test]
    fn non_utf8_nix_output() -> std::io::Result<()> {
        let tmp = tempfile::tempdir()?;
        let cas = ContentAddressable::new(tmp.path().to_owned())?;
        let drv = |name: &str, args: &str| {
            format!(
                r##"
derivation {{
  name = "{}";
  builder = "/bin/sh";
  allowSubstitutes = false;
  preferLocalBuild = true;
  system = builtins.currentSystem;
  # this is to make nix rebuild for every test, I’m so sorry
  random = {:?};
  {}
}}"##,
                name,
                tmp.path(),
                args
            )
        };

        let nix_drv = format!(
            r##"
let dep = {};
in {}
"##,
            drv(
                "dep",
                r##"
  args = [
    "-c"
    ''
    # non-utf8 sequence to stdout (which is nix stderr)
    printf '"\xab\xbc\xcd\xde\xde\xef"'
    echo > $out
    ''
  ];"##
            ),
            drv("shell", "inherit dep;")
        );

        print!("{}", nix_drv);

        let info = run(&::NixFile::from(cas.file_from_string(&nix_drv)?), &cas).unwrap();
        assert!(info.exec_result.success());
        Ok(())
    }
}
