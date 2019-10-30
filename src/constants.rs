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

/// Everything that can happen when creating `Paths`.
/// Mostly filesystem access problems.
#[derive(Debug)]
pub enum PathsInitError {
    /// The `gc_root_dir` creation failed.
    #[allow(missing_docs)]
    GcRootsDirectoryCantBeCreated {
        gc_root_dir: PathBuf,
        err: std::io::Error,
    },
    /// The `socket_dir` creation failed.
    #[allow(missing_docs)]
    SocketDirCantBeCreated {
        socket_dir: PathBuf,
        err: std::io::Error,
    },
    /// The CAS creation failed.
    #[allow(missing_docs)]
    CasCantBeCreated {
        cas_dir: PathBuf,
        err: std::io::Error,
    },
}

impl Paths {
    /// Set up project paths, creating directories if necessary.
    pub fn initialize() -> Result<Paths, PathsInitError> {
        let pd = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("Could not determine lorri project/cache directories, please set $HOME");
        let create_dir = |dir: PathBuf| -> std::io::Result<PathBuf> {
            std::fs::create_dir_all(&dir).and(Ok(dir))
        };
        let gc_root_dir = pd.cache_dir().join("gc_roots");
        let runtime_dir = pd
            .runtime_dir()
            // fall back to the cache dir on non-linux
            .unwrap_or_else(|| pd.cache_dir())
            .to_owned();
        let cas_dir = pd.cache_dir().join("cas");
        Ok(Paths {
            gc_root_dir: create_dir(gc_root_dir.clone()).map_err(|err| {
                PathsInitError::GcRootsDirectoryCantBeCreated { gc_root_dir, err }
            })?,
            daemon_socket_file: create_dir(runtime_dir.clone())
                .map_err(|err| PathsInitError::SocketDirCantBeCreated {
                    socket_dir: runtime_dir,
                    err,
                })?
                .join("daemon.socket"),
            cas_store: ContentAddressable::new(cas_dir.clone())
                .map_err(|err| PathsInitError::CasCantBeCreated { cas_dir, err })?,
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
