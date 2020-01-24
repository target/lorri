//! Open up a project shell

use crate::builder;
use crate::builder::RunStatus;
use crate::nix::CallOpts;
use crate::ops::error::{ExitError, OpResult};
use crate::project::{roots::Roots, Project};
use crossbeam_channel as chan;
use slog_scope::debug;
use std::io;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{Duration, Instant};
use std::{env, fs, thread};

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let shell = env::var("SHELL").expect("lorri shell requires $SHELL to be set");
    debug!("using shell path {}", shell);

    let tempdir = tempfile::tempdir().expect("failed to create temporary directory");
    let mut bash_cmd = bash_cmd(project, tempdir.path())?;
    debug!("bash"; "command" => ?bash_cmd);
    bash_cmd
        .args(&["-c", &format!("exec {}", shell)])
        .status()
        .expect("failed to execute bash");
    Ok(())
}

/// Instantiates a `Command` to start bash.
pub fn bash_cmd(project: Project, tempdir: &Path) -> Result<Command, ExitError> {
    let (tx, rx) = chan::unbounded();
    thread::spawn(move || {
        eprint!("lorri: building environment");
        let mut last = Instant::now();
        for msg in rx {
            // Set the maximum rate of the "progress bar"
            if last.elapsed() >= Duration::from_millis(500) {
                eprint!(".");
                io::stderr().flush().unwrap();
                last = Instant::now();
            }
            debug!("build"; "message" => ?msg);
        }
        eprintln!(". done");
    });

    let run_result = builder::run(tx, &project.nix_file, &project.cas)
        .map_err(|e| ExitError::temporary(format!("build failed: {:?}", e)))?;
    let build = match run_result.status {
        RunStatus::Complete(build) => Roots::from_project(&project)
            .create_roots(build)
            .map_err(|e| ExitError::temporary(format!("rooting the environment failed: {:?}", e))),
        e => Err(ExitError::temporary(format!("build failed: {:?}", e))),
    }?;

    let init_file = tempdir.join("init");
    fs::write(
        &init_file,
        format!(
            r#"
EVALUATION_ROOT="{}"

{}"#,
            build.shell_gc_root,
            include_str!("direnv/envrc.bash")
        ),
    )
    .expect("failed to write shell output");

    debug!("building bash via runtime closure"; "closure" => crate::RUN_TIME_CLOSURE);
    let bash_path = CallOpts::expression(&format!("(import {}).path", crate::RUN_TIME_CLOSURE))
        .value::<PathBuf>()
        .expect("failed to get runtime closure path");

    let mut cmd = Command::new(bash_path.join("bash"));
    cmd.env(
        "BASH_ENV",
        init_file
            .to_str()
            .expect("script file path not UTF-8 clean"),
    );
    Ok(cmd)
}
