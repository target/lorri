//! The info callable is for printing

use crate::ops::error::{ok, OpResult};
use crate::VERSION_BUILD_REV;
use std::path::PathBuf;

/// See the documentation for lorri::cli::Command::Info for more
/// details.
pub fn main(shell_nix: PathBuf) -> OpResult {
    println!("lorri version: {}", VERSION_BUILD_REV);
    println!("Lorri Project Configuration");
    println!();

    println!("expression: {}", shell_nix.display());

    ok()
}
