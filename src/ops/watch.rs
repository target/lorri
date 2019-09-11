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
        match msg {
            // TODO: add human-message to get a nice stack & link for people to open an issue
            Err(unrecoverable) => panic!(
                "An unrecoverable error has occured. Please open an issue!\n{:#?}",
                unrecoverable
            ),
            Ok(m) => println!("{:#?}", m),
        }
    }

    build_thread.join().unwrap();

    ok()
}
