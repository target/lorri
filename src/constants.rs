//! Global project constants.

extern crate directories;

use self::directories::ProjectDirs;
use std::path::{Path, PathBuf};

/// Path constants like the GC root directory.
pub struct Paths {
    gc_root_dir: PathBuf,
    daemon_socket_file: PathBuf,
}

impl Paths {
    /// Set up project paths
    pub fn new() -> Paths {
        let pd = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("Could not determine lorri project/cache directories, please set $HOME");
        Paths {
            gc_root_dir: pd.cache_dir().join("gc_roots"),
            daemon_socket_file: pd.cache_dir().join("daemon.socket"),
        }
    }

    /// Default location in the user's XDG directories to keep
    /// GC root pins
    pub fn gc_root_dir(&self) -> &Path {
        &self.gc_root_dir
    }

    /// Path to the socket file.
    ///
    /// The daemon uses this path to create its Unix socket on
    /// (see `::daemon` and `::socket::communicate`).
    pub fn daemon_socket_file(&self) -> &Path {
        &self.daemon_socket_file
    }
}
