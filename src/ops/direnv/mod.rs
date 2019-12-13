//! Emit shell script intended to be evaluated as part of direnv's .envrc

mod version;

use self::version::{DirenvVersion, MIN_DIRENV_VERSION};
use crate::ops::error::{ok, ExitError, OpResult};
use crate::project::roots::Roots;
use crate::project::Project;
use crate::rpc;
use slog_scope::{error, info, warn};
use std::process::Command;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main<W: std::io::Write>(project: Project, mut shell_output: W) -> OpResult {
    check_direnv_version()?;

    let root_paths = Roots::from_project(&project).paths();
    let paths_are_cached: bool = root_paths.all_exist();
    let address = crate::ops::get_paths()?.daemon_socket_address();
    let shell_nix = rpc::ShellNix {
        path: project.shell_nix.to_string(),
    };

    let ping_sent = if let Ok(connection) = varlink::Connection::with_address(&address) {
        use rpc::VarlinkClientInterface;
        rpc::VarlinkClient::new(connection)
            .watch_shell(shell_nix)
            .call()
            .is_ok()
    } else {
        false
    };

    match (ping_sent, paths_are_cached) {
        (true, true) => {}

        // Ping sent & paths aren't cached: once the environment is created
        // the direnv environment will be updated automatically.
        (true, false) =>
            info!(
                "lorri has not completed an evaluation for this project yet"
            ),

        // Ping not sent and paths are cached: we can load a stale environment
        // When the daemon is started, we'll send a fresh ping.
        (false, true) =>
            info!(
                "lorri daemon is not running, loading a cached environment"
            ),

        // Ping not sent and paths are not cached: we can't load anything,
        // but when the daemon in started we'll send a ping and eventually
        // load a fresh environment.
        (false, false) =>
            error!("lorri daemon is not running and this project has not yet been evaluated, please run `lorri daemon`"),
    }

    if std::env::var("DIRENV_IN_ENVRC") != Ok(String::from("1")) {
        warn!("`lorri direnv` should be executed by direnv from within an `.envrc` file")
    }

    // direnv interprets stdout as a script that it evaluates. That is why (1) the logger for
    // `lorri direnv` outputs to stderr by default (to avoid corrupting the script) and (2) we
    // can't use the stderr logger here.
    // In production code, `shell_output` will be stdout so direnv can interpret the output.
    // `shell_output` is an argument so that testing code can inject a different `std::io::Write`
    // in order to inspect the output.
    writeln!(
        shell_output,
        r#"
EVALUATION_ROOT="{}"

watch_file "{}"
watch_file "$EVALUATION_ROOT"

{}"#,
        root_paths.shell_gc_root,
        crate::ops::get_paths()?
            .daemon_socket_file()
            .to_str()
            .expect("Socket path is not UTF-8 clean!"),
        include_str!("envrc.bash")
    )
    .expect("failed to write shell output");

    ok()
}

/// Checks `direnv version` against the minimal version lorri requires.
fn check_direnv_version() -> OpResult {
    let out = with_command("direnv", |mut cmd| cmd.arg("version").output())?;
    let version = std::str::from_utf8(&out.stdout)
        .map_err(|_| ())
        .and_then(|utf| utf.trim_end().parse::<DirenvVersion>())
        .map_err(|()| {
            ExitError::environment_problem(
                "Could not figure out the current `direnv` version (parse error)".to_string(),
            )
        })?;
    if version < MIN_DIRENV_VERSION {
        Err(ExitError::environment_problem(format!(
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
    res.map_err(|a| {
        ExitError::missing_executable(match a.kind() {
            std::io::ErrorKind::NotFound => format!("`{}`: executable not found", executable),
            _ => format!("Could not start `{}`: {}", executable, a),
        })
    })
}
