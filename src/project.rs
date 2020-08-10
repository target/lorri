//! Wrap a nix file and manage corresponding state.

pub mod roots;

use crate::cas::ContentAddressable;
use crate::NixFile;
use std::fs::File;
use std::io::prelude::*;
use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};

/// A “project” knows how to handle the lorri state
/// for a given nix file.
#[derive(Clone)]
pub struct Project {
    /// Absolute path to this project’s nix file.
    pub nix_file: NixFile,

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
        nix_file: NixFile,
        gc_root_dir: &Path,
        cas: ContentAddressable,
    ) -> std::io::Result<Project> {
        let nix_file_path = nix_file.as_path().as_os_str().as_bytes();

        let hash = format!("{:x}", md5::compute(nix_file_path));
        let project_dir = gc_root_dir.join(&hash);
        let project_gc_root = project_dir.join("gc_root");

        std::fs::create_dir_all(&project_gc_root)?;

        let mut file = File::create(project_dir.join("ref"))?;
        file.write_all(nix_file_path)?;

        Ok(Project {
            nix_file,
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
