//! The info callable is for printing

use crate::ops::{ok, OpResult};
use crate::project;
use crate::VERSION_BUILD_REV;

/// See the documentation for lorri::cli::Command::Info for more
/// details.
pub fn main(project: &project::Project) -> OpResult {
    println!("lorri version: {}", VERSION_BUILD_REV);
    println!("Lorri Project Configuration");
    println!();

    println!(" project root: {}", project.project_root.display());

    println!(" project name: {}", project.name());
    println!("   expression: {}", project.expression().display());

    ok()
}
