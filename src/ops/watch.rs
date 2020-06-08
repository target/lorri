//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.

use crate::build_loop::BuildLoop;
use crate::cli::WatchOptions;
use crate::nix::options::NixOptions;
use crate::ops::error::{ok, ExitError, OpResult};
use crate::project::Project;
use crossbeam_channel as chan;
use slog_scope::info;
use std::fmt::Debug;
use std::thread;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project, opts: WatchOptions) -> OpResult {
    if opts.once {
        main_run_once(project)
    } else {
        main_run_forever(project)
    }
}

fn main_run_once(project: Project) -> OpResult {
    // TODO: add the ability to pass extra_nix_options to watch
    let mut build_loop = BuildLoop::new(&project, NixOptions::empty());
    match build_loop.once() {
        Ok(msg) => {
            print_build_message(msg);
            ok()
        }
        Err(e) => {
            if e.is_actionable() {
                Err(ExitError::expected_error(format!("{:#?}", e)))
            } else {
                Err(ExitError::temporary(format!("{:?}", e)))
            }
        }
    }
}

fn main_run_forever(project: Project) -> OpResult {
    let (tx, rx) = chan::unbounded();
    let build_thread = {
        thread::spawn(move || {
            // TODO: add the ability to pass extra_nix_options to watch
            let mut build_loop = BuildLoop::new(&project, NixOptions::empty());

            // The `watch` command does not currently react to pings, hence the `chan::never()`
            build_loop.forever(tx, chan::never());
        })
    };

    for msg in rx {
        print_build_message(msg);
    }

    build_thread.join().unwrap();

    ok()
}

/// Print a build message to stdout and flush.
fn print_build_message<A>(msg: A)
where
    A: Debug,
{
    info!("build message"; "message" => ?msg);
}
