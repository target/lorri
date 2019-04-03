//! TODO
use std::env;
use std::os::unix::fs::symlink;
use std::path::PathBuf;

/// Roots manipulation
#[derive(Clone)]
pub struct Roots {
    root_dir: PathBuf,
    id: String,
}

impl Roots {
    /// Create a Roots struct to manage roots within the root_dir
    /// directory.
    ///
    /// `id` is a unique identifier for this project's checkout.
    pub fn new(root_dir: PathBuf, id: String) -> Roots {
        Roots { root_dir, id }
    }

    /// Store a new root under name
    pub fn add(&self, name: &str, store_path: &PathBuf) -> Result<PathBuf, AddRootError> {
        let mut path = self.root_dir.clone();
        path.push(name);

        debug!("Adding root from {:?} to {:?}", store_path, path,);
        check_permission(
            ignore_missing(std::fs::remove_file(&path)),
            &format!("Can’t remove {}", path.display()),
        )?;

        check_permission(
            symlink(&store_path, &path),
            &format!(
                "Can’t symlink {} to {}",
                store_path.display(),
                path.display()
            ),
        )?;

        // this is bad.
        let mut root = PathBuf::from("/nix/var/nix/gcroots/per-user");
        // TODO: check on start
        root.push(env::var("USER").expect("env var 'USER' must be set"));

        // The user directory sometimes doesn’t exist,
        // but we can create it (it’s root but `rwxrwxrwx`)
        ensure_directory_exists(&root);

        root.push(format!("{}-{}", self.id, name));

        debug!("Connecting root from {:?} to {:?}", path, root,);
        check_permission(
            ignore_missing(std::fs::remove_file(&root)),
            &format!("Can’t remove {}", root.display()),
        )?;
        check_permission(
            symlink(&path, &root),
            &format!("Can’t symlink {} to {}", path.display(), root.display()),
        )?;

        Ok(path)
    }
}

/// Check if a directory exists and is a directory.
/// Try to create it if nothing’s there.
/// Panic for everything else.
fn ensure_directory_exists(dir: &PathBuf) {
    match std::fs::metadata(dir) {
        Err(e) => {
            if let std::io::ErrorKind::NotFound = e.kind() {
                std::fs::create_dir(dir).unwrap_or_else(|_| {
                    panic!(
                        "directory {} does not exist and we can’t create it",
                        dir.display()
                    )
                })
            }
        }
        Ok(meta) => {
            if !meta.is_dir() {
                panic!("{} is not a directory", dir.display())
            }
        }
    }
}

/// Ignore a `NotFound` error.
fn ignore_missing(err: std::io::Result<()>) -> std::io::Result<()> {
    err.or_else(|e| match e.kind() {
        std::io::ErrorKind::NotFound => Ok(()),
        _ => Err(e),
    })
}

/// Take a result and panic if there was a `PermissionDenied` error.
fn check_permission(err: std::io::Result<()>, permission_errormsg: &str) -> std::io::Result<()> {
    err.or_else(|e| match e.kind() {
        std::io::ErrorKind::PermissionDenied => {
            panic!(format!("Permission denied. {}", permission_errormsg))
        }
        _ => Err(e),
    })
}

/// Error conditions encountered when adding roots
#[derive(Debug)]
pub enum AddRootError {
    /// IO-related errors
    Io(std::io::Error),
}

impl From<std::io::Error> for AddRootError {
    fn from(e: std::io::Error) -> AddRootError {
        AddRootError::Io(e)
    }
}
