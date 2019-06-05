//! Global project constants.

extern crate directories;

use self::directories::ProjectDirs;
use std::path::{Path, PathBuf};

/// Path constants like the GC root directory.
pub struct Paths {
    // project_dir: ProjectDirs,
    gc_root_dir: PathBuf,
}

impl Paths {
    /// Set up project paths
    pub fn new() -> Paths {
        let pd = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("Could not determine lorri project/cache directories, please set $HOME");
        let gcrd = pd.cache_dir().join("gc_roots");
        Paths {
            // project_dir: pd,
            gc_root_dir: gcrd,
        }
    }

    /// Default location in the user's XDG directories to keep
    /// GC root pins
    pub fn gc_root_dir(&self) -> &Path {
        &self.gc_root_dir
    }
}
