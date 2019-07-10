//! Project-level functions, like preferred configuration
//! and on-disk locations.

use std::io;
use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};
use NixFile;

/// A specific project which we are operating on
#[derive(Debug)]
pub struct Project<'a, 'b> {
    /// The file on disk to the shell.nix
    pub nix_file: &'a NixFile,

    /// Directory, in which garbage collection roots will be stored
    pub base_gc_root_path: &'b Path,
}

/// Error conditions encountered when finding and loading a Lorri
/// config file.
#[derive(Debug)]
pub enum ProjectLoadError {
    /// The shell.nix was not found in a directory search.
    ConfigNotFound,

    /// An IO error occured while finding the project
    Io(io::Error),
}

impl<'a, 'b> Project<'a, 'b> {
    /// Given an absolute path to a shell.nix,
    /// construct a Project and a ProjectConfig.
    pub fn new(nix_file: &'a NixFile, gc_root: &'b Path) -> Project<'a, 'b> {
        Project {
            nix_file,
            base_gc_root_path: gc_root,
        }
    }

    /// Absolute path to the the project's primary entry points
    /// expression
    pub fn expression(&self) -> &NixFile {
        &self.nix_file
    }

    /// Absolute path to the projects' gc root directory, for pinning
    /// build and evaluation products
    pub fn gc_root_path(&self) -> Result<PathBuf, std::io::Error> {
        // TODO: use a hash of the project’s abolute path here
        // to avoid collisions
        // TODO: move to ContentAddressable
        let path = self.base_gc_root_path.join(self.hash()).join("gc_root");

        if !path.is_dir() {
            debug!("Creating all directories for GC roots in {:?}", path);
            std::fs::create_dir_all(&path)?;
        }

        Ok(path.to_path_buf())
    }

    /// Generate a "unique" ID for this project based on its absolute path
    pub fn hash(&self) -> String {
        // TODO: move to ContentAddressable
        format!("{:x}", md5::compute(self.nix_file.as_os_str().as_bytes()))
    }
}
