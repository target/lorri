//! Run a BuildLoop for `shell.nix`, but only once.
//! Can be used together with `direnv`.
use crate::build_loop::BuildLoop;
use crate::ops::{ok, OpResult};
use crate::project::Project;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(project: Project) -> OpResult {
    let mut build_loop = BuildLoop::new(&project);
    let result = build_loop.once();

    println!("{:#?}", result);
    ok()
}
