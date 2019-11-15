//! Helpers for locating files off disk.

use crate::AbsPathBuf;
use std::env;
use std::io;
use std::path::PathBuf;

/// Error conditions encountered when hunting for a file on disk
#[derive(Debug)]
pub enum FileLocationError {
    /// An IO error was encountered when traversing the directory
    /// stack
    Io(io::Error),

    /// No file by this name was found
    NotFound,
}

impl From<std::io::Error> for FileLocationError {
    fn from(e: std::io::Error) -> FileLocationError {
        FileLocationError::Io(e)
    }
}

/// Search for `name` in the current directory.
/// If `name` is an absolute path, it returns `name`.
pub fn in_cwd(name: &PathBuf) -> Result<AbsPathBuf, FileLocationError> {
    let path = AbsPathBuf::new(env::current_dir()?)
        .unwrap_or_else(|orig| {
            panic!(
                "Expected `env::current_dir` to return an absolute path, but was {}",
                orig.display()
            )
        })
        .join(name);
    if path.as_absolute_path().is_file() {
        Ok(path)
    } else {
        Err(FileLocationError::NotFound)
    }
}

#[cfg(test)]
mod tests {
    use super::{in_cwd, FileLocationError};
    use crate::AbsPathBuf;
    use std::path::PathBuf;

    #[test]
    fn test_locate_config_file() {
        let mut path = PathBuf::from("shell.nix");
        let result = in_cwd(&path);
        assert_eq!(
            result.expect("Should find the shell.nix in this projects' root"),
            AbsPathBuf::new(PathBuf::from(env!("CARGO_MANIFEST_DIR")))
                .unwrap()
                .join("shell.nix")
        );
        path.pop();
        path.push("this-lorri-specific-file-probably-does-not-exist");
        let result = in_cwd(&path);

        match result {
            Err(FileLocationError::NotFound) => (),
            _ => panic!("unexpected result: {:?}", result),
        }
    }
}
