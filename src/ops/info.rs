//! The info callable is for printing

use crate::builder::OutputPaths;
use crate::ops::error::{ok, OpResult};
use crate::project::{roots::Roots, Project};
use slog_scope::info;

/// See the documentation for lorri::cli::Command::Info for more
/// details.
pub fn main(project: Project) -> OpResult {
    let root_paths = Roots::from_project(&project).paths();
    let OutputPaths { shell_gc_root } = &root_paths;
    if root_paths.all_exist() {
        info!("gc roots exist"; "shell_gc_root" => ?shell_gc_root.as_os_str());
    } else {
        info!("gc roots do not exist"; "shell_gc_root" => ?shell_gc_root.as_os_str());
    }
    ok()
}
