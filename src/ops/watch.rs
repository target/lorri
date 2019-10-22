//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::build_loop::{BuildError, BuildLoop};
use crate::cli::WatchOptions;
use crate::ops::{err, ok, OpResult};
use crate::project::Project;
use std::fmt::Debug;
use std::io::Write;
use std::sync::mpsc::channel;
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
        Err(BuildError::Unrecoverable(e)) => err(100, format!("{:?}", e)),
        Err(BuildError::Recoverable(failure)) => err(1, format!("{:#?}", failure)),
    }
}

fn main_run_forever(project: Project) -> OpResult {
    let (tx, rx) = channel();
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
