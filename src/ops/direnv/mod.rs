//! Emit shell script intended to be evaluated as part of direnv's .envrc

use crate::ops::{ExitError, OpResult};
use crate::project::Project;
use std::process::Command;
use std::str::FromStr;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main(project: Project) -> OpResult {
    check_direnv_version()?;

    let mut shell_root = project.gc_root_path().unwrap();
    shell_root.push("build-0"); // !!!

    println!(
        r#"
EVALUATION_ROOT="{}"

{}
"#,
        shell_root.display(),
        include_str!("envrc.bash")
    );

    Ok(())
}

#[derive(PartialEq, Eq)]
struct DirenvVersion(usize, usize, usize);

const MIN_DIRENV_VERSION: DirenvVersion = DirenvVersion(2, 19, 2);

/// `"a.b.c"`, e.g. `"2.19.2"`.
impl FromStr for DirenvVersion {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let ss = s.split('.').collect::<Vec<&str>>();
        let parse = |s: &str| s.parse::<usize>().or_else(|_| Err(()));
        match *ss {
            [major, minor, patch] => Ok(DirenvVersion(
                parse(major)?,
                parse(minor)?,
                parse(patch)?
            )),
            _ => Err(()),
        }
    }
}

impl std::fmt::Display for DirenvVersion {
    fn fmt(&self, fmt: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(fmt, "{}.{}.{}", self.0, self.1, self.2)
    }
}

/// Essentially just semver, first field, then second, then third.
impl Ord for DirenvVersion {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.0
            .cmp(&other.0)
            .then(self.1.cmp(&other.1))
            .then(self.2.cmp(&other.2))
    }
}

impl PartialOrd for DirenvVersion {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

/// Checks `direnv version` against the minimal version lorri requires.
fn check_direnv_version() -> OpResult {
    let out = with_command("direnv", |mut cmd| cmd.arg("version").output())?;
    let version = std::str::from_utf8(&out.stdout)
        .map_err(|_| ())
        .and_then(|utf| utf.trim_end().parse::<DirenvVersion>())
        .map_err(|()| ExitError {
            exitcode: 1,
            message: "Could not figure out the current `direnv` version (parse error)".to_string(),
        })?;
    if version < MIN_DIRENV_VERSION {
        ExitError::errmsg(format!(
            "`direnv` is version {}, but >= {} is required for lorri to function",
            version, MIN_DIRENV_VERSION
        ))
    } else {
        Ok(())
    }
}

/// constructs a `Command` out of `executable`
/// Recognizes the case in which the executable is missing,
/// and converts it to a corresponding `ExitError`.
fn with_command<T, F>(executable: &str, cmd: F) -> Result<T, ExitError>
where
    F: FnOnce(Command) -> std::io::Result<T>,
{
    let res = cmd(Command::new(executable));
    res.map_err(|a| ExitError {
        // TODO: other exit code for missing executable?
        exitcode: 1,
        message: match a.kind() {
            std::io::ErrorKind::NotFound => format!("`{}`: executable not found", executable),
            _ => format!("Could not start `{}`: {}", executable, a),
        },
    })
}
