//! Run nix-build on the project, doing as much caching and adding
//! as much user-friendly sauce as possible.

use crate::ops::{ExitError, OpResult};
use crate::project::Project;

/// See the documentation for lorri::cli::Command::Build for more
/// details.
pub fn main(project: &Project) -> OpResult {
    ExitError::errmsg(format!(
        "run `nix-build {}` yourself! :)",
        project.project_root.display()
    ))
}
