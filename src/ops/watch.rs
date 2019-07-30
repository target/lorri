//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::build_loop::BuildLoop;
use crate::ops::{ok, OpResult};
use crate::project::Project;
use std::sync::mpsc::channel;
use std::thread;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let (tx, rx) = channel();

    let build_thread = {
        thread::spawn(move || {
            let mut build_loop = BuildLoop::new(&project);
            build_loop.forever(tx);
        })
    };

    for msg in rx {
        println!("{:#?}", msg);
    }

    build_thread.join().unwrap();

    ok()
}
