//! Open up a project shell

use crate::build::{BuildInstruction, NixBuild};
use crate::build_loop::{BuildLoop, Event};
use crate::ops::{ok, ExitError, OpResult};
use crate::project::Project;
use crate::roots::Roots;
use std::process::Command;
use std::sync::mpsc::channel;
use std::thread;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let (tx, rx) = channel();
    let root_nix_file = &project.expression();
    let roots = Roots::new(project.gc_root_path().unwrap(), project.id());
    let mut build_loop = BuildLoop::new(root_nix_file.clone(), roots.clone());

    println!(
        "WARNING: lorri shell is very simplistic and not suppported at the moment. \
         Please use the other commands."
    );

    let initial_build_thread = thread::spawn(move || {
        let result = build_loop.once();

        (result, build_loop)
    });

    debug!("Building bash...");
    let bash = NixBuild::build(&BuildInstruction::Expression(
        "(import <nixpkgs> {}).bashInteractive.out",
    ))
    .expect("Failed to get a bashInteractive")
    .pop()
    .expect("Failed to receive a bash path");

    debug!("running with bash: {:?}", bash);
    roots.add("bash", &bash).unwrap();

    println!("Waiting for the builder to produce a drv for the 'shell' attribute.");

    let (initial_result, mut build_loop) = initial_build_thread
        .join()
        .expect("Failed to join the initial evaluation thread");

    let first_build = match initial_result {
        Ok(e) => e,
        Err(e) => {
            return ExitError::errmsg(format!(
                "Build for {} never produced a successful result: {:#?}",
                root_nix_file.display(),
                e
            ));
        }
    };

    // the `shell` derivation is required in oder to start a shell
    // TODO: is this actually a derivation? Or an attribute?
    let shell_drv = first_build
        .named_drvs
        .get("shell")
        .expect("Failed to start the shell: no \"shell\" derivation found");

    let build_thread = {
        thread::spawn(move || {
            build_loop.forever(tx);
        })
    };

    // Move the channel to a new thread to log all remaining builds.
    let msg_handler_thread = thread::spawn(move || {
        for mes in rx {
            print_build_event(&mes)
        }
    });

    Command::new("nix-shell")
        .arg(shell_drv)
        .env("NIX_BUILD_SHELL", format!("{}/bin/bash", bash.display()))
        .env("LORRI_SHELL_ROOT", shell_drv)
        .env("PROMPT_COMMAND", include_str!("./prompt.sh"))
        .status()
        .expect("Failed to execute bash");

    drop(build_thread);
    drop(msg_handler_thread);

    ok()
}

// Log all failing builds, return an iterator of the first
// build that succeeds.
fn print_build_event(ev: &Event) {
    match ev {
        Event::Completed(_) => {
            eprintln!("Expressions re-evaluated. Press enter to reload the environment.")
        }
        Event::Started => eprintln!("Evaluation started"),
        // show the last 5 lines of error output
        Event::Failure(err) => eprintln!(
            "Evaluation failed: \n{}",
            err.log_lines[err.log_lines.len().saturating_sub(5)..].join("\n")
        ),
    }
}
