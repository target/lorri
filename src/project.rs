//! Project-level functions, like preferred configuration
//! and on-disk locations.

use locate_file;
use locate_file::FileLocationError;
use std::io;
use std::os::unix::ffi::OsStrExt;
use std::path::PathBuf;
use NixFile;

/// A specific project which we are operating on
#[derive(Debug)]
pub struct Project {
    /// The file on disk to the shell.nix
    pub nix_file: NixFile,

    // TODO: completely superfluous, lorri only needs
    // to know about the nix file
    /// The root directory containing the project's files
    pub project_root: PathBuf,

    /// Directory, in which garbage collection roots will be stored
    base_gc_root_path: PathBuf,
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

impl From<FileLocationError> for ProjectLoadError {
    fn from(err: FileLocationError) -> ProjectLoadError {
        match err {
            FileLocationError::NotFound => ProjectLoadError::ConfigNotFound,
            FileLocationError::Io(io) => ProjectLoadError::Io(io),
        }
    }
}

impl Project {
    /// Load a Project based on the current working directory,
    /// locating a `shell.nix` configuration file in the current
    /// directory.
    pub fn from_cwd() -> Result<Project, ProjectLoadError> {
        let shell_nix = locate_file::in_cwd("shell.nix")?;

        Project::load(
            NixFile(shell_nix),
            ::constants::Paths::initialize()
                // TODO: don’t initialize in here
                .expect("Error: cannot initialize lorri paths")
                .gc_root_dir()
                .to_owned(),
        )
    }

    /// Given an absolute path to a shell.nix,
    /// construct a Project and a ProjectConfig.
    pub fn load(nix_file: NixFile, gc_root: PathBuf) -> Result<Project, ProjectLoadError> {
        // TODO: remove the ability to get the parent of a nix file
        let project_root = nix_file
            .0
            .parent()
            // only None if `shell_nix` is "/"
            .unwrap();

        Ok(Project {
            project_root: project_root.to_path_buf(),
            nix_file: nix_file.clone(),
            base_gc_root_path: gc_root,
        })
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
        let path = self.base_gc_root_path.join(self.hash()).join("gc_root");

        if !path.is_dir() {
            debug!("Creating all directories for GC roots in {:?}", path);
            std::fs::create_dir_all(&path)?;
        }

        Ok(path.to_path_buf())
    }

    /// Generate a "unique" ID for this project based on its absolute path
    pub fn hash(&self) -> String {
        format!(
            "{:x}",
            md5::compute(self.project_root.as_os_str().as_bytes())
        )
    }
}
