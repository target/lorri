//! Helpers for locating files off disk.

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

/// Hunt for filename `name` in the current directory.
/// If `path` is absolute, it returns `path`.
pub fn in_cwd(name: &PathBuf) -> Result<PathBuf, FileLocationError> {
    let mut path = env::current_dir()?;
    path.push(name);
    if path.is_file() {
        Ok(path)
    } else {
        Err(FileLocationError::NotFound)
    }
}

#[cfg(test)]
mod tests {
    use super::{in_cwd, FileLocationError};
    use std::path::Path;
    use std::path::PathBuf;

    #[test]
    fn test_locate_config_file() {
        let mut path = PathBuf::from("shell.nix");
        let result = in_cwd(&path);
        assert_eq!(
            result.expect("Should find the shell.nix in this projects' root"),
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("shell.nix")
                .to_path_buf()
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
