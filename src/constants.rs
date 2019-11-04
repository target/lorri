//! Global project constants.

extern crate directories;

use self::directories::ProjectDirs;
use crate::cas::ContentAddressable;
use crate::AbsPathBuf;

/// Path constants like the GC root directory.
pub struct Paths {
    gc_root_dir: AbsPathBuf,
    daemon_socket_file: AbsPathBuf,
    cas_store: ContentAddressable,
}

/// Everything that can happen when creating `Paths`.
/// Mostly filesystem access problems.
#[derive(Debug)]
pub enum PathsInitError {
    /// The `gc_root_dir` creation failed.
    #[allow(missing_docs)]
    GcRootsDirectoryCantBeCreated {
        gc_root_dir: AbsPathBuf,
        err: std::io::Error,
    },
    /// The `socket_dir` creation failed.
    #[allow(missing_docs)]
    SocketDirCantBeCreated {
        socket_dir: AbsPathBuf,
        err: std::io::Error,
    },
    /// The CAS creation failed.
    #[allow(missing_docs)]
    CasCantBeCreated {
        cas_dir: AbsPathBuf,
        err: std::io::Error,
    },
}

impl Paths {
    /// Set up project paths, creating directories if necessary.
    pub fn initialize() -> Result<Paths, PathsInitError> {
        let pd = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("Could not determine lorri project/cache directories, please set $HOME");
        let create_dir = |dir: AbsPathBuf| -> std::io::Result<AbsPathBuf> {
            std::fs::create_dir_all(&dir).and(Ok(dir))
        };

        // TODO: return as good error value
        assert!(
            pd.cache_dir().is_absolute(),
            "Your cache directory is not an absolute path! It is: {}",
            pd.cache_dir().display()
        );
        let abs_cache_dir = AbsPathBuf::new_unchecked(pd.cache_dir().to_owned());
        let gc_root_dir = abs_cache_dir.join("gc_roots");
        let cas_dir = abs_cache_dir.join("cas");
        let runtime_dir = pd
            .runtime_dir()
            // fall back to the cache dir on non-linux
            .unwrap_or_else(|| pd.cache_dir())
            .to_owned();
        // TODO: return as good error value
        assert!(
            runtime_dir.is_absolute(),
            "Your runtime directory is not an absolute path! It is: {}",
            runtime_dir.display()
        );
        let abs_runtime_dir = AbsPathBuf::new_unchecked(runtime_dir);

        Ok(Paths {
            gc_root_dir: create_dir(abs_cache_dir.join("gc_roots")).map_err(|err| {
                PathsInitError::GcRootsDirectoryCantBeCreated { gc_root_dir, err }
            })?,
            daemon_socket_file: create_dir(abs_runtime_dir.clone())
                .map_err(|err| PathsInitError::SocketDirCantBeCreated {
                    socket_dir: abs_runtime_dir,
                    err,
                })?
                .join("daemon.socket"),
            cas_store: ContentAddressable::new(abs_cache_dir.join("cas"))
                .map_err(|err| PathsInitError::CasCantBeCreated { cas_dir, err })?,
        })
    }

    /// Default location in the user's XDG directories to keep
    /// GC root pins
    pub fn gc_root_dir(&self) -> &AbsPathBuf {
        &self.gc_root_dir
    }

    /// Path to the socket file.
    ///
    /// The daemon uses this path to create its Unix socket on
    /// (see `::daemon` and `::socket::communicate`).
    pub fn daemon_socket_file(&self) -> &AbsPathBuf {
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
