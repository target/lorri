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
        ignore_missing(std::fs::remove_file(&path))?;
        symlink(&store_path, &path)?;

        // this is bad.
        let mut root = PathBuf::from("/nix/var/nix/gcroots/per-user");
        root.push(env::var("USER").expect("env var 'USER' must be set"));
        root.push(format!("{}-{}", self.id, name));

        debug!("Connecting root from {:?} to {:?}", path, root,);
        ignore_missing(std::fs::remove_file(&root))?;
        symlink(&path, &root)?;

        Ok(path)
    }
}

fn ignore_missing(err: Result<(), std::io::Error>) -> Result<(), std::io::Error> {
    if let Err(e) = err {
        match e.kind() {
            std::io::ErrorKind::NotFound => Ok(()),
            _ => Err(e),
        }
    } else {
        Ok(())
    }
}

/// Error conditions encountered when adding roots
#[derive(Debug)]
pub enum AddRootError {
    /// IO-related errors
    Io(std::io::Error),

    /// Execution time errors
    FailureToAdd,
}

impl From<std::io::Error> for AddRootError {
    fn from(e: std::io::Error) -> AddRootError {
        AddRootError::Io(e)
    }
}
