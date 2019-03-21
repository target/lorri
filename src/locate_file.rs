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

/// Hunt for filename `name` in the current directory
pub fn in_cwd(name: &str) -> Result<PathBuf, FileLocationError> {
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

    #[test]
    fn test_locate_config_file() {
        let result = in_cwd("shell.nix");
        assert_eq!(
            result.expect("Should find the shell.nix in this projects' root"),
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("shell.nix")
                .to_path_buf()
        );

        let result = in_cwd("this-lorri-specific-file-probably-does-not-exist");

        match result {
            Err(FileLocationError::NotFound) => (),
            _ => panic!("unexpected result: {:?}", result),
        }
    }
}
