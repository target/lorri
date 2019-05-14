//! Project-level functions, like preferred configuration
//! and on-disk locations.

use directories::ProjectDirs;
use locate_file;
use locate_file::FileLocationError;
use std::io;
use std::os::unix::ffi::OsStrExt;
use std::path::PathBuf;

/// A specific project which we are operating on
#[derive(Debug)]
pub struct Project {
    /// The file on disk to the shell.nix
    pub shell_nix: PathBuf,

    /// The root directory containing the project's files
    pub project_root: PathBuf,

    /// Directory, in which garbage collection roots will be stored
    gc_root: PathBuf,
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

        Project::load(shell_nix, Project::default_gc_root_dir())
    }

    /// Default location in the user's XDG directories to keep
    /// GC root pins
    pub fn default_gc_root_dir() -> PathBuf {
        let project_dir = ProjectDirs::from("com.github.target.lorri", "lorri", "lorri")
            .expect("could not derive a gc root directory, please set XDG variables");

        project_dir.cache_dir().to_path_buf()
    }

    /// Given a path to a shell.nix, construct a Project and a ProjectConfig.
    pub fn load(shell_nix: PathBuf, gc_root: PathBuf) -> Result<Project, ProjectLoadError> {
        let project_root = shell_nix
            .parent()
            // only None if `shell_nix` is "/"
            .unwrap();

        Ok(Project {
            project_root: project_root.to_path_buf(),
            shell_nix: shell_nix.clone(),
            gc_root,
        })
    }

    /// The project's human readable name
    pub fn name(&self) -> &str {
        &self
            .project_root
            .file_name()
            .expect("unable to identify directory name of the project root")
            .to_str()
            .unwrap()
    }

    /// Absolute path to the the project's primary entry points
    /// expression
    pub fn expression(&self) -> PathBuf {
        self.shell_nix.clone()
    }

    /// Absolute path to the projects' gc root directory, for pinning
    /// build and evaluation products
    pub fn gc_root_path(&self) -> Result<PathBuf, std::io::Error> {
        let path = self.gc_root.join(self.name()).join("gc_root");

        if !path.is_dir() {
            debug!("Creating all directories for GC roots in {:?}", path);
            std::fs::create_dir_all(&path)?;
        }

        Ok(path.to_path_buf())
    }

    /// Generate a "unique" ID for this project based on where it is
    /// cloned and its name
    pub fn id(&self) -> String {
        format!(
            "{:x}-{:x}",
            md5::compute(self.name()),
            md5::compute(self.project_root.as_os_str().as_bytes())
        )
    }
}
