//! Open up a project shell

use crate::build_loop::{BuildLoop, Event};
use crate::nix::CallOpts;
use crate::ops::error::{ExitError, OpResult};
use crate::project::Project;
use crossbeam_channel as chan;
use slog_scope::{debug, info, warn};
use std::path::PathBuf;
use std::process::Command;
use std::{fs, thread};

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    warn!(
        "lorri shell is very simplistic and not suppported at the moment. \
         Please use the other commands."
    );

    let (tx, rx) = chan::unbounded();
    let _build_thread = {
        let project = project.clone();
        thread::spawn(move || {
            BuildLoop::new(&project).forever(tx, chan::never());
        })
    };

    debug!("building bash via runtime closure"; "closure" => crate::RUN_TIME_CLOSURE);
    let bash_path = CallOpts::expression(&format!("(import {}).path", crate::RUN_TIME_CLOSURE))
        .value::<PathBuf>()
        .expect("failed to get runtime closure path");

    let first_build = rx
        .iter()
        .find_map(|mes| match mes {
            Event::Completed(res) => Some(res),
            s @ Event::Started(_) => {
                print_build_event(&s);
                None
            }
            f @ Event::Failure(_) => {
                print_build_event(&f);
                None
            }
        })
        .map_or(
            Err(ExitError::panic(format!(
                "Build for {:?} never produced a successful result",
                &project.nix_file,
            ))),
            Ok,
        )?;

    // Move the channel to a new thread to log all remaining builds.
    let _msg_handler_thread = thread::spawn(move || {
        for mes in rx {
            print_build_event(&mes)
        }
    });

    let tempdir = tempfile::tempdir().expect("failed to create temporary directory");
    let script_file = tempdir.path().join("activate");

    fs::write(
        &script_file,
        format!(
            r#"
EVALUATION_ROOT="{}"

{}"#,
            first_build.output_paths.shell_gc_root,
            include_str!("direnv/envrc.bash")
        ),
    )
    .expect("failed to write shell output");

    let mut shell = Command::new(bash_path.join("bash"));
    debug!("bash"; "cmd" => ?&shell);
    shell
        .args(&[
            "--init-file",
            script_file
                .to_str()
                .expect("script file path not UTF-8 clean"),
        ])
        .status()
        .expect("failed to execute bash");

    Ok(())
}

// Log all failing builds, return an iterator of the first
// build that succeeds.
fn print_build_event(ev: &Event) {
    match ev {
        Event::Completed(_) => {
            info!("Expressions re-evaluated. Press enter to reload the environment.")
        }
        Event::Started(_) => debug!("Evaluation started"),
        // show the last 5 lines of error output
        Event::Failure(err) => warn!(
            "Evaluation failed: \n{}",
            err.log_lines[err.log_lines.len().saturating_sub(5)..]
                .iter()
                .map(|o| format!("{:?}", o))
                .collect::<Vec<_>>()
                .join("\n")
        ),
    }
}
