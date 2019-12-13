//! Wrap a nix file and manage corresponding state.

pub mod roots;

use crate::cas::ContentAddressable;
use crate::NixFile;
use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};

/// A “project” knows how to handle the lorri state
/// for a given nix file.
#[derive(Clone)]
pub struct Project {
    /// Absolute path to this project’s shell nix file.
    pub shell_nix: NixFile,

    /// Directory in which this project’s
    /// garbage collection roots are stored.
    gc_root_path: PathBuf,

    /// Hash of the nix file’s absolute path.
    hash: String,

    /// Content-addressable store to save static files in
    pub cas: ContentAddressable,
}

impl Project {
    /// Construct a `Project` from nix file path
    /// and the base GC root directory
    /// (as returned by `Paths.gc_root_dir()`),
    pub fn new(
        shell_nix: NixFile,
        gc_root_dir: &Path,
        cas: ContentAddressable,
    ) -> std::io::Result<Project> {
        let hash = format!("{:x}", md5::compute(shell_nix.as_os_str().as_bytes()));
        let project_gc_root = gc_root_dir.join(&hash).join("gc_root").to_path_buf();

        std::fs::create_dir_all(&project_gc_root)?;

        Ok(Project {
            shell_nix,
            gc_root_path: project_gc_root,
            hash,
            cas,
        })
    }

    /// Generate a "unique" ID for this project based on its absolute path.
    pub fn hash(&self) -> &str {
        &self.hash
    }
}
