//! Simple content-addressable file-based store.
//!
//! Give it an empty directory to save the files in,
//! then call the `file_from_*` methods to write contents
//! to the CAS. The content is hashed and a new file is only
//! written if the content hasn’t been added before.
//!
//! Internally uses md5, don’t use for security-critical stuff.
use std::io::Write;
use std::path::PathBuf;

extern crate atomicwrites;

/// A content-addressable store.
#[derive(Clone)]
pub struct ContentAddressable {
    store_dir: PathBuf,
}

impl ContentAddressable {
    /// Create a new content-addressable store.
    ///
    /// The `store_dir` *must* be an empty directory
    /// (created if it does not yet exist), or a directory
    /// pointing to another `ContentAddressable` store.
    /// If it is a directory with some other data,
    /// the correctness cannot be guaranteed.
    ///
    /// TODO: assert that it’s an absolute path
    pub fn new(store_dir: PathBuf) -> std::io::Result<ContentAddressable> {
        std::fs::create_dir_all(&store_dir)?;
        Ok(ContentAddressable { store_dir })
    }

    /// Adds the contents to a file in the content-addressable store
    /// and returns the `PathBuf` pointing to the file.
    ///
    /// If the same contents were already written, the existing file
    /// is returned.
    ///
    /// This operation hashes the file contents, its cost is at least
    /// the cost of hashing the `content` string.
    pub fn file_from_string(&self, content: &str) -> std::io::Result<PathBuf> {
        use self::atomicwrites::{AtomicFile, OverwriteBehavior};

        // md5 should be okay, since this is not security-critical
        let hash = format!("{:x}", md5::compute(content.as_bytes()));

        let file_name = self.store_dir.join(hash);

        // shortcut: if the file is already there,
        // we don’t have to write it a second time.
        if let Err(e) = std::fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .open(&file_name)
        {
            // since we use create_new, it will tell us if the file
            // exists; in that case it was already written (same hash),
            // so we don’t have to write it anew.
            if let std::io::ErrorKind::AlreadyExists = e.kind() {
                return Ok(file_name);
            }
            // We can ignore errors, it will either not matter
            // or be rethrown by the code below.
        }

        // creates a temporary directory in a subfolder of the cas dir
        AtomicFile::new_with_tmpdir(
            &file_name,
            // We can allow overwrites,
            // because the same file will be written should it happen
            OverwriteBehavior::AllowOverwrite,
            // This cannot conflict with our content files,
            // because it uses a prefix for its filenames
            &self.store_dir,
        )
        .write(|f| f.write_all(content.as_bytes()))
        .map_err(std::io::Error::from)?;

        Ok(file_name)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Tests adding some content to the store and whether
    /// the returned file path contains the same content.
    #[test]
    fn save_and_check_same_content() -> std::io::Result<()> {
        let content = "this is content";
        let store_dir = tempfile::tempdir()?;
        let cas_file = ContentAddressable::new(store_dir.path().to_owned())
            .unwrap()
            .file_from_string(content)
            .unwrap();

        // small check to check that the file lives in store_path
        assert_eq!(store_dir.path().to_owned(), cas_file.parent().unwrap());
        // the content should be the same in the file that was written
        Ok(assert_eq!(
            content,
            std::str::from_utf8(&std::fs::read(cas_file)?).unwrap()
        ))
    }

    /// Ensures that adding the same content twice does not write
    /// the same file again.
    #[test]
    fn writing_the_same_content_doesnt_write_file() -> std::io::Result<()> {
        let content = "this is content";
        let store_dir = tempfile::tempdir()?;
        let cas = ContentAddressable::new(store_dir.path().to_owned()).unwrap();
        let cas_file = cas.file_from_string(content).unwrap();

        let first_mtime = cas_file.metadata()?.modified()?;

        // creating a cas for the same content doesn’t write to the file
        let cas_file_new = cas.file_from_string(content).unwrap();

        let second_mtime = cas_file_new.metadata()?.modified()?;

        // if the mtimes are different, the file has been overwritten
        assert_eq!(first_mtime, second_mtime);
        Ok(())
    }
}
