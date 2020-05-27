//! The info callable is for printing

use crate::builder::OutputPaths;
use crate::ops::error::{ok, OpResult};
use crate::project::{roots::Roots, Project};
use std::path::PathBuf;

/// See the documentation for lorri::cli::Command::Info for more
/// details.
pub fn main(project: Project) -> OpResult {
    println!("lorri version: {}", crate::LORRI_VERSION);
    let root_paths = Roots::from_project(&project).paths();
    let OutputPaths { shell_gc_root } = &root_paths;
    println!(
        "Nix shell file: {}",
        PathBuf::from(&project.nix_file).display()
    );
    if root_paths.all_exist() {
        println!(
            "GC roots exist, shell_gc_root: {:?}",
            shell_gc_root.as_os_str()
        );
    } else {
        println!("GC roots do not exist. Has the project been built with lorri yet?",);
    }
    ok()
}
