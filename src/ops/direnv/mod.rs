//! Emit shell script intended to be evaluated as part of direnv's .envrc

mod version;

use self::version::{DirenvVersion, MIN_DIRENV_VERSION};
use crate::ops::{ok, ok_msg, ExitError, OpResult};
use crate::project::Project;
use std::process::Command;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main(project: &Project) -> OpResult {
    check_direnv_version()?;

    let mut shell_root = project.gc_root_path().unwrap();
    shell_root.push("build-0"); // !!!

    if !shell_root.exists() {
        return ExitError::errmsg("Please run 'lorri watch' before using direnv integration.");
    }

    if std::env::var("DIRENV_IN_ENVRC") != Ok(String::from("1")) {
        eprintln!(
            "Warning: 'lorri direnv' should be executed by direnv from within an `.envrc` file."
        )
    }

    ok_msg(format!(
        r#"
EVALUATION_ROOT="{}"

watch_file "$EVALUATION_ROOT"

{}
"#,
        shell_root.display(),
        include_str!("envrc.bash")
    ))
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
        ok()
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
