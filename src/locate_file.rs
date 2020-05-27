//! Helpers for locating files off disk.

use std::env;
use std::io;
use std::path::Path;
use std::path::PathBuf;

/// Error conditions encountered when hunting for a file on disk
#[derive(Debug)]
pub enum FileLocationError {
    /// An IO error was encountered when traversing the directory
    /// stack
    Io(io::Error),

    /// No file by this name was found
    NotFound,

    /// The specified file is not part of project in current directory
    PathNotInProject,
}

impl From<std::io::Error> for FileLocationError {
    fn from(e: std::io::Error) -> FileLocationError {
        FileLocationError::Io(e)
    }
}

/// If `name` is relative path, hunt in current directory
/// else if `name` is absolute path, hunt in a parent directory.
pub fn by_name(name: &PathBuf) -> Result<PathBuf, FileLocationError> {
    let cwd = env::current_dir()?;
    in_cwd(&cwd, name)
}

fn in_cwd(cwd: &Path, name: &PathBuf) -> Result<PathBuf, FileLocationError> {
    let path = if name.is_absolute() {
        name.to_path_buf()
    } else {
        cwd.join(name)
    };

    if path.is_file() {
        let parent = path.parent().unwrap();
        if cwd.ancestors().any(|a| a == parent) {
            Ok(path.to_path_buf())
        } else {
            Err(FileLocationError::PathNotInProject)
        }
    } else {
        Err(FileLocationError::NotFound)
    }
}

#[cfg(test)]
mod tests {
    use super::{by_name, in_cwd, FileLocationError};
    use std::env;
    use std::path::Path;
    use std::path::PathBuf;

    #[test]
    fn test_locate_config_file_by_name() {
        let cwd = Path::new(env!("CARGO_MANIFEST_DIR"));
        let name = PathBuf::from("shell.nix");
        let abs_path = cwd.join(name.to_path_buf());

        let result = by_name(&name);
        assert_eq!(
            result.expect("Should find the shell.nix by name in this projects' root"),
            abs_path
        );

        let result = by_name(&abs_path);
        assert_eq!(
            result.expect("Should find the shell.nix in current directory by full path"),
            abs_path
        );

        let result = by_name(&PathBuf::from("lorri-nix-file?-bveuy5guk"));
        match result {
            Err(FileLocationError::NotFound) => (),
            _ => panic!("Should not non existing file: {:?}", result),
        }
    }

    #[test]
    fn test_locate_config_file_in_cwd() {
        let cwd = Path::new(env!("CARGO_MANIFEST_DIR"));
        let name = PathBuf::from("shell.nix");
        let abs_path = cwd.join(name.to_path_buf());

        let subdir = cwd.join("src");
        let result = in_cwd(&subdir, &abs_path);
        assert_eq!(
            result.expect("Should find the shell.nix in ./src directory by full path"),
            abs_path
        );

        let result = in_cwd(&subdir, &name);
        match result {
            Err(FileLocationError::NotFound) => (),
            _ => panic!("Should not find by name in ./src directory: {:?}", result),
        }

        let result = in_cwd(&cwd.parent().unwrap(), &abs_path);
        match result {
            Err(FileLocationError::PathNotInProject) => (),
            _ => panic!("Should not find by path ouside project: {:?}", result),
        }

        let result = in_cwd(&env::temp_dir(), &abs_path);
        match result {
            Err(FileLocationError::PathNotInProject) => (),
            _ => panic!("Should not find by path ouside project: {:?}", result),
        }
    }
}
