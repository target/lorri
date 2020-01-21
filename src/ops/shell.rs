//! Open up a project shell

use crate::build_loop::BuildLoop;
use crate::nix::CallOpts;
use crate::ops::error::{ExitError, OpResult};
use crate::project::Project;
use slog_scope::{debug, warn};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    warn!(
        "lorri shell is very simplistic and not suppported at the moment. \
         Please use the other commands."
    );

    debug!("building project environment");
    let build = BuildLoop::new(&project)
        .once()
        .map_err(|e| ExitError::temporary(format!("build failed: {:?}", e)))?;

    debug!("building bash via runtime closure"; "closure" => crate::RUN_TIME_CLOSURE);
    let bash_path = CallOpts::expression(&format!("(import {}).path", crate::RUN_TIME_CLOSURE))
        .value::<PathBuf>()
        .expect("failed to get runtime closure path");

    let tempdir = tempfile::tempdir().expect("failed to create temporary directory");
    let init_file = tempdir.path().join("init");

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

    let mut shell = Command::new(bash_path.join("bash"));
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
