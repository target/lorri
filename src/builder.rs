//! Builds a nix derivation file (like a `shell.nix` file).
//!
//! It is a wrapper around `nix-build`.
//!
//! Note: this does not build the Nix expression as-is.
//! It instruments various nix builtins in a way that we
//! can parse additional information from the `nix-build`
//! `stderr`, like which source files are used by the evaluator.

use regex::Regex;
use std::any::Any;
use std::collections::HashMap;
use std::io::{BufRead, BufReader};
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::thread;

/// Builds the Nix expression in `root_nix_file`.
///
/// Instruments the nix file to gain extra information,
/// which is valuable even if the build fails.
pub fn run(root_nix_file: &PathBuf) -> Result<Info, Error> {
    // We're looking for log lines matching:
    //
    //     copied source '...' -> '/nix/store/...'
    //     evaluating file '...'
    //
    // to determine which files we should setup watches on.
    // Increasing verbosity by two levels via `-vv` satisfies that.

    let mut child = Command::new("nix-build")
        .args(&[
            "-vv",
            "--expr",
            include_str!("./logged-evaluation.nix"),
            "--no-out-link",
            "--arg",
            "runTimeClosure",
            crate::RUN_TIME_CLOSURE,
            "--arg",
            "src",
        ])
        .arg(root_nix_file)
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    let stdout = child
        .stdout
        .take()
        .expect("we must be able to access the stdout of nix-build");
    let stderr = child
        .stderr
        .take()
        .expect("we must be able to access the stderr of nix-build");

    let stderr_results: thread::JoinHandle<Vec<LogDatum>> = thread::spawn(move || {
        let reader = BufReader::new(stderr);
        reader
            .lines()
            .map(|line| parse_evaluation_line(&line.unwrap()))
            .collect::<Vec<LogDatum>>()
    });

    let produced_drvs: thread::JoinHandle<Vec<PathBuf>> = thread::spawn(move || {
        BufReader::new(stdout)
            .lines()
            .map(|line| PathBuf::from(line.unwrap()))
            .collect::<Vec<PathBuf>>()
    });

    let (exec_result, drvs, results) =
        (child.wait()?, produced_drvs.join()?, stderr_results.join()?);

    let (paths, named_drvs, log_lines): (Vec<PathBuf>, HashMap<String, PathBuf>, Vec<String>) =
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
        drvs,
        named_drvs,
        paths,
        log_lines,
    })
}

#[derive(Debug, PartialEq)]
enum LogDatum {
    Source(PathBuf),
    AttrDrv(String, PathBuf),
    Text(String),
}

/// Examine a line of output and extract interesting log items in to
/// structured data.
fn parse_evaluation_line(line: &str) -> LogDatum {
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

    // Lines about evaluating a file are much more common, so looking
    // for them first will reduce comparisons.
    if let Some(matches) = EVAL_FILE.captures(&line) {
        LogDatum::Source(PathBuf::from(&matches["source"]))
    } else if let Some(matches) = COPIED_SOURCE.captures(&line) {
        LogDatum::Source(PathBuf::from(&matches["source"]))
    } else if let Some(matches) = LORRI_READ.captures(&line) {
        LogDatum::Source(PathBuf::from(&matches["source"]))
    } else if let Some(matches) = LORRI_ATTR_DRV.captures(&line) {
        LogDatum::AttrDrv(
            String::from(&matches["attribute"]),
            PathBuf::from(&matches["drv"]),
        )
    } else {
        LogDatum::Text(String::from(line))
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
    pub log_lines: Vec<String>,
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
    use super::{parse_evaluation_line, LogDatum};
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
            LogDatum::Text(String::from(
                "downloading 'https://static.rust-lang.org/dist/channel-rust-stable.toml'..."
            ))
        );
    }
}
