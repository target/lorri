//! Emit shell script intended to be evaluated as part of direnv's .envrc

mod version;

use self::version::{DirenvVersion, MIN_DIRENV_VERSION};
use crate::ops::{ok, ok_msg, ExitError, OpResult};
use crate::project::roots::Roots;
use crate::project::Project;
use crate::socket::communicate::client;
use crate::socket::communicate::{Ping, DEFAULT_READ_TIMEOUT};
use std::process::Command;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main(project: Project) -> OpResult {
    check_direnv_version()?;

    // TODO: don’t start build/evaluation automatically, let the user decide
    if let Ok(client) = client::ping(DEFAULT_READ_TIMEOUT).connect(
        &::socket::path::SocketPath::from(::ops::get_paths()?.daemon_socket_file()),
    ) {
        client
            .write(&Ping {
                nix_file: project.nix_file.clone(),
            })
            .unwrap();
    } else {
        eprintln!("Uh oh, your lorri daemon is not running.");
    }

    let root_paths = Roots::from_project(&project).paths();

    if !root_paths.all_exist() {
        return Err(ExitError::errmsg(
            "Please start `lorri daemon` or run `lorri watch` before using direnv integration.",
        ));
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
        root_paths.shell_gc_root,
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
        Err(ExitError::errmsg(format!(
            "`direnv` is version {}, but >= {} is required for lorri to function",
            version, MIN_DIRENV_VERSION
        )))
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
