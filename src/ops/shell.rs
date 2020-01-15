//! Open up a project shell

use crate::build_loop::{BuildLoop, Event};
use crate::nix::CallOpts;
use crate::ops::error::{ExitError, OpResult};
use crate::project::roots::Roots;
use crate::project::Project;
use crossbeam_channel as chan;
use slog_scope::{debug, info, warn};
use std::path::PathBuf;
use std::process::Command;
use std::thread;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let (tx, rx) = chan::unbounded();
    let root_nix_file = &project.nix_file;
    let roots = Roots::from_project(&project);

    let _build_thread = {
        let project = project.clone();
        thread::spawn(move || {
            BuildLoop::new(&project).forever(tx, chan::never());
        })
    };

    warn!(
        "lorri shell is very simplistic and not suppported at the moment. \
         Please use the other commands."
    );

    debug!("Building bash...");
    let bash: PathBuf = CallOpts::expression("(import <nixpkgs> {}).bashInteractive.out")
        .value::<PathBuf>()
        .expect("Failed to get a bashInteractive");

    debug!("running with bash: {:?}", bash);
    roots
        .add_path("bash", &bash)
        .expect("Failed to add GC root for bashInteractive");

    debug!("Waiting for the builder to produce a drv for the 'shell' attribute.");

    // Log all failing builds, return an iterator of the first
    // build that succeeds.
    let first_build_opt = rx.iter().find_map(|mes| match mes {
        Event::Completed(res) => Some(res),
        s @ Event::Started(_) => {
            print_build_event(&s);
            None
        }
        f @ Event::Failure(_) => {
            print_build_event(&f);
            None
        }
    });

    let first_build = match first_build_opt {
        Some(e) => e,
        None => {
            return Err(ExitError::panic(format!(
                "Build for {:?} never produced a successful result",
                root_nix_file
            )));
        }
    };

    // the `shell` derivation is required in oder to start a shell
    // TODO: is this actually a derivation? Or an attribute?
    let shell_drv = first_build
        .shell_drv
        .expect("No shell derivation found in build");

    // Move the channel to a new thread to log all remaining builds.
    let _msg_handler_thread = thread::spawn(move || {
        for mes in rx {
            print_build_event(&mes)
        }
    });

    let mut nix_shell = Command::new("nix-shell");
    nix_shell
        .arg(shell_drv.as_os_str())
        .env("NIX_BUILD_SHELL", format!("{}/bin/bash", bash.display()))
        .env("LORRI_SHELL_ROOT", shell_drv)
        .env("PROMPT_COMMAND", include_str!("./prompt.sh"));
    debug!("nix-shell"; "cmd" => ?&nix_shell);
    nix_shell.status().expect("Failed to execute bash");

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
