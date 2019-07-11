//! Wrap a nix file and manage corresponding state.

use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};
use NixFile;

/// A “project” knows how to handle the lorri state
/// for a given nix file.
#[derive(Debug)]
pub struct Project<'a, 'b> {
    /// Absolute path to this project’s nix file.
    pub nix_file: &'a NixFile,

    /// Directory in which all lorri garbage collection roots are stored.
    base_gc_root_path: &'b Path,
}

impl<'a, 'b> Project<'a, 'b> {
    /// Construct a `Project` from nix file path
    /// and the base GC root directory
    /// (as returned by `Paths.gc_root_dir()`),
    pub fn new(nix_file: &'a NixFile, gc_root_dir: &'b Path) -> Project<'a, 'b> {
        Project {
            nix_file,
            base_gc_root_path: gc_root_dir,
        }
    }

    /// Absolute path to the projects' gc root directory, for pinning
    /// build and evaluation products.
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

    /// Generate a "unique" ID for this project based on its absolute path.
    pub fn hash(&self) -> String {
        // TODO: move to ContentAddressable
        format!("{:x}", md5::compute(self.nix_file.as_os_str().as_bytes()))
    }
}
