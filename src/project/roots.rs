//! Handling of nix GC roots
//!
//! TODO: inline this module into `::project`
use crate::project::Project;
use builder::{OutputPaths, RootedPath};
use nix::StorePath;
use std::env;
use std::path::{Path, PathBuf};

/// Roots manipulation
#[derive(Clone)]
pub struct Roots {
    /// The GC root directory in the lorri user cache dir
    gc_root_path: PathBuf,
    id: String,
}

/// A path to a gc root.
#[derive(Hash, PartialEq, Eq, Clone, Debug, Serialize, Deserialize)]
pub struct RootPath(PathBuf);

impl RootPath {
    /// Underlying `&OsStr`.
    pub fn as_os_str(&self) -> &std::ffi::OsStr {
        self.0.as_os_str()
    }
}

impl OutputPaths<RootPath> {
    /// Check whether all all GC roots exist.
    pub fn all_exist(&self) -> bool {
        match self {
            // Match here to ensure we cover every field
            ::builder::OutputPaths { shell_gc_root } => shell_gc_root.0.exists(),
        }
    }

    /// Check that the shell_gc_root is a directory.
    pub fn shell_gc_root_is_dir(&self) -> bool {
        match self.shell_gc_root.0.metadata() {
            Err(_) => false,
            Ok(m) => m.is_dir(),
        }
    }
}

/// Proxy through the `Display` class for `PathBuf`.
impl std::fmt::Display for RootPath {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        self.0.display().fmt(f)
    }
}

impl Roots {
    // TODO: all use-cases are from_project; just save a reference to a project?
    /// Construct a Roots struct based on a project's GC root directory
    /// and ID.
    pub fn from_project(project: &Project) -> Roots {
        Roots {
            gc_root_path: project.gc_root_path.to_path_buf(),
            id: project.hash().to_string(),
        }
    }

    /// Return the filesystem paths for these roots.
    pub fn paths(&self) -> OutputPaths<RootPath> {
        OutputPaths {
            shell_gc_root: RootPath(self.gc_root_path.join("shell_gc_root")),
        }
    }

    /// Create roots to store paths.
    pub fn create_roots(
        &self,
        // Important: this intentionally only allows creating
        // roots to `StorePath`, not to `DrvFile`, because we have
        // no use case for creating GC roots for drv files.
        path: RootedPath,
    ) -> Result<OutputPaths<RootPath>, AddRootError>
where {
        Ok(OutputPaths {
            shell_gc_root: self.add("shell_gc_root", &path.path)?,
        })
    }

    /// Store a new root under name
    fn add(&self, name: &str, store_path: &StorePath) -> Result<RootPath, AddRootError> {
        // final path in the `self.gc_root_path` directory
        let mut path = self.gc_root_path.clone();
        path.push(name);

        debug!("Adding root from {:?} to {:?}", store_path.as_path(), path,);
        std::fs::remove_file(&path).or_else(|e| AddRootError::remove(e, &path))?;

        std::fs::remove_file(&path).or_else(|e| AddRootError::remove(e, &path))?;

        // the forward GC root that points from the store path to our cache gc_roots dir
        std::os::unix::fs::symlink(store_path.as_path(), &path)
            .map_err(|e| AddRootError::symlink(e, store_path.as_path(), &path))?;

        // the reverse GC root that points from nix to our cache gc_roots dir
        let mut root = if let Ok(path) = env::var("NIX_STATE_DIR") {
            PathBuf::from(path)
        } else {
            PathBuf::from("/nix/var/nix/")
        };
        root.push("gcroots");
        root.push("per-user");

        // TODO: check on start of lorri
        root.push(env::var("USER").expect("env var 'USER' must be set"));

        // The user directory sometimes doesn’t exist,
        // but we can create it (it’s root but `rwxrwxrwx`)
        if !root.is_dir() {
            std::fs::create_dir_all(&root).map_err(|e| AddRootError::create_dir_all(e, &root))?;
        }

        root.push(format!("{}-{}", self.id, name));

        debug!("Connecting root from {:?} to {:?}", path, root,);
        std::fs::remove_file(&root).or_else(|e| AddRootError::remove(e, &root))?;

        std::os::unix::fs::symlink(&path, &root)
            .map_err(|e| AddRootError::symlink(e, &path, &root))?;

        // TODO: don’t return the RootPath here
        Ok(RootPath(path))
    }
}

/// Error conditions encountered when adding roots
#[derive(Debug)]
pub enum AddRootError {
    /// IO-related errors
    Io(std::io::Error, String),
}

impl AddRootError {
    /// Create a contextualized error around failing to create a directory
    fn create_dir_all(err: std::io::Error, path: &Path) -> AddRootError {
        AddRootError::Io(
            err,
            format!("Failed to recursively create directory {}", path.display()),
        )
    }

    /// Ignore NotFound errors (it is after all a remove), and otherwise
    /// return an error explaining a delete on path failed.
    fn remove(err: std::io::Error, path: &Path) -> Result<(), AddRootError> {
        if err.kind() == std::io::ErrorKind::NotFound {
            Ok(())
        } else {
            Err(AddRootError::Io(
                err,
                format!("Failed to delete {}", path.display()),
            ))
        }
    }

    /// Return an error explaining what symlink failed
    fn symlink(err: std::io::Error, src: &Path, dest: &Path) -> AddRootError {
        AddRootError::Io(
            err,
            format!("Failed to symlink {} to {}", src.display(), dest.display()),
        )
    }
}
