//! Global project constants.

extern crate directories;

use self::directories::ProjectDirs;
use cas::ContentAddressable;
use std::path::{Path, PathBuf};

/// Path constants like the GC root directory.
pub struct Paths {
    gc_root_dir: PathBuf,
    daemon_socket_file: PathBuf,
    cas_store: ContentAddressable,
}

impl Paths {
    /// Set up project paths, creating directories if necessary.
    pub fn initialize() -> std::io::Result<Paths> {
        let pd = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("Could not determine lorri project/cache directories, please set $HOME");
        let create_dir = |dir: PathBuf| -> std::io::Result<PathBuf> {
            std::fs::create_dir_all(&dir).and(Ok(dir))
        };
        Ok(Paths {
            gc_root_dir: create_dir(pd.cache_dir().join("gc_roots"))?,
            daemon_socket_file: create_dir(
                pd.runtime_dir()
                    // fall back to the cache dir on non-linux
                    .unwrap_or_else(|| pd.cache_dir())
                    .to_owned(),
            )?
            .join("daemon.socket"),
            cas_store: ContentAddressable::new(pd.cache_dir().join("cas"))?,
        })
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

    /// content-addressable store.
    ///
    /// It should be used to reify strings that are needed as files,
    /// e.g. nix expressions.
    pub fn cas_store(&self) -> &ContentAddressable {
        &self.cas_store
    }
}
