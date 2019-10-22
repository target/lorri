//! Emit shell script intended to be evaluated as part of direnv's .envrc

mod version;

use self::version::{DirenvVersion, MIN_DIRENV_VERSION};
use crate::ops::{ok, ok_msg, err, ExitError, OpResult};
use crate::project::roots::Roots;
use crate::project::Project;
use crate::socket::communicate::client;
use crate::socket::communicate::{Ping, DEFAULT_READ_TIMEOUT};
use std::process::Command;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main(project: Project) -> OpResult {
    check_direnv_version()?;

    let socket_path = ::ops::get_paths()?.daemon_socket_file().to_owned();

    let root_paths = Roots::from_project(&project).paths();
    let paths_are_cached: bool = root_paths.all_exist();

    let ping_sent: bool = if let Ok(client) = client::ping(DEFAULT_READ_TIMEOUT).connect(
        &::socket::path::SocketPath::from(::ops::get_paths()?.daemon_socket_file()),
    ) {
        client
            .write(&Ping {
                nix_file: project.nix_file.clone(),
            })
            .unwrap();
        true
    } else {
        false
    };

    match (ping_sent, paths_are_cached) {
        (true, true) => {}

        // Ping sent & paths aren't cached: once the environment is created
        // the direnv environment will be updated automatically.
        (true, false) => {
            eprintln!("Notice: lorri has not completed an evaluation for this project yet.");
            eprintln!("        lorri should be evaluating the environment now.");
        }

        // Ping not sent and paths are cached: we can load a stale environment
        // When the daemon is started, we'll send a fresh ping.
        (false, true) => {
            eprintln!("Info: the lorri daemon is not running. Loading a cached environment.");
        }

        // Ping not sent and paths are not cached: we can't load anything,
        // but when the daemon in started we'll send a ping and eventually
        // load a fresh environment.
        (false, false) => {
            eprintln!("Error: the lorri daemon is not running and this project has not yet been evaluated.");
            eprintln!("       Please run `lorri daemon`.");
        }
    }

    if std::env::var("DIRENV_IN_ENVRC") != Ok(String::from("1")) {
        eprintln!(
            "Warning: 'lorri direnv' should be executed by direnv from within an `.envrc` file."
        )
    }

    ok_msg(format!(
        r#"
EVALUATION_ROOT="{}"

watch_file "{}"
watch_file "$EVALUATION_ROOT"

{}
"#,
        root_paths.shell_gc_root,
        socket_path
            .into_os_string()
            .into_string()
            .expect("Socket path is not UTF-8 clean!"),
        include_str!("envrc.bash")
    ))
}

/// Checks `direnv version` against the minimal version lorri requires.
fn check_direnv_version() -> OpResult {
    let out = with_command("direnv", |mut cmd| cmd.arg("version").output())?;
    let version = std::str::from_utf8(&out.stdout)
        .map_err(|_| ())
        .and_then(|utf| utf.trim_end().parse::<DirenvVersion>())
        .map_err(|()| ExitError::errmsg("Could not figure out the current `direnv` version (parse error)"))?;
    if version < MIN_DIRENV_VERSION {
        err(1, format!(
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
    res.map_err(|a| ExitError::errmsg( // TODO: other exit code for missing executable?
             match a.kind() {
                std::io::ErrorKind::NotFound => format!("`{}`: executable not found", executable),
                _ => format!("Could not start `{}`: {}", executable, a),
            }))
}
