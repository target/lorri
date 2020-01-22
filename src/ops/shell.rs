//! Open up a project shell

use crate::build_loop::BuildLoop;
use crate::nix::CallOpts;
use crate::ops::error::{ExitError, OpResult};
use crate::project::Project;
use slog_scope::debug;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let tempdir = tempfile::tempdir().expect("failed to create temporary directory");
    let (init_file, mut shell) = bash(project, tempdir.path())?;
    debug!("bash"; "command" => ?&shell);
    shell
        .args(&[
            "--init-file",
            init_file
                .to_str()
                .expect("script file path not UTF-8 clean"),
        ])
        .status()
        .expect("failed to execute bash");
    Ok(())
}

/// Instantiates a `Command` to start bash.
pub fn bash(project: Project, tempdir: &Path) -> Result<(PathBuf, Command), ExitError> {
    debug!("building project environment");
    let build = BuildLoop::new(&project)
        .once()
        .map_err(|e| ExitError::temporary(format!("build failed: {:?}", e)))?;

    let init_file = tempdir.join("init");
    fs::write(
        &init_file,
        format!(
            r#"
EVALUATION_ROOT="{}"

{}"#,
            build.output_paths.shell_gc_root,
            include_str!("direnv/envrc.bash")
        ),
    )
    .expect("failed to write shell output");

    debug!("building bash via runtime closure"; "closure" => crate::RUN_TIME_CLOSURE);
    let bash_path = CallOpts::expression(&format!("(import {}).path", crate::RUN_TIME_CLOSURE))
        .value::<PathBuf>()
        .expect("failed to get runtime closure path");

    Ok((init_file, Command::new(bash_path.join("bash"))))
}
