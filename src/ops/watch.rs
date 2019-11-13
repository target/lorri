//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.

use crate::build_loop::{BuildError, BuildLoop};
use crate::cli::WatchOptions;
use crate::ops::{ok, ExitError, OpResult};
use crate::project::Project;
use crossbeam_channel as chan;
use std::fmt::Debug;
use std::io::Write;
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
    let mut build_loop = BuildLoop::new(&project);
    match build_loop.once() {
        Ok(msg) => {
            print_build_message(msg);
            ok()
        }
        Err(BuildError::Unrecoverable(err)) => Err(ExitError::err(100, format!("{:?}", err))),
        Err(BuildError::Recoverable(exit_failure)) => {
            Err(ExitError::errmsg(format!("{:#?}", exit_failure)))
        }
    }
}

fn main_run_forever(project: Project) -> OpResult {
    let (tx, rx) = chan::unbounded();
    let build_thread = {
        thread::spawn(move || {
            let mut build_loop = BuildLoop::new(&project);
            build_loop.forever(tx);
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
    println!("{:#?}", msg);
    let _ = std::io::stdout().flush();
}
