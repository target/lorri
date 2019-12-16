//! `bind()`ing & `connect()`ing to sockets.

use std::os::unix::io::AsRawFd;
use std::path::{Path, PathBuf};

/// Small wrapper that makes sure lorri sockets are handled correctly.
pub struct SocketPath(PathBuf);

/// Binding to the socket failed.
#[derive(Debug)]
pub enum BindError {
    /// Another process is listening on the socket
    OtherProcessListening(PathBuf),
    /// I/O error
    Io(std::io::Error),
    /// nix library I/O error (like Io)
    Unix(nix::Error),
}

impl From<BindError> for crate::ops::error::ExitError {
    fn from(e: BindError) -> crate::ops::error::ExitError {
        crate::ops::error::ExitError::temporary(format!("Bind error: {:?}", e))
    }
}

impl From<std::io::Error> for BindError {
    fn from(e: std::io::Error) -> BindError {
        BindError::Io(e)
    }
}

/// Locks the socket the server is bound to. Drop to release.
pub struct BindLock(std::fs::File);

impl SocketPath {
    /// Create from the path of the socket.
    /// Must be passed a valid socket file path (ending in a file name).
    pub fn from(socket_path: &Path) -> SocketPath {
        SocketPath(socket_path.to_path_buf())
    }

    /// Try to lock the lock file to find outswhether another process is listening.
    pub fn lock(&self) -> Result<BindLock, BindError> {
        let h = std::fs::OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(self.lockfile())?;
        // we try to get an exclusive lock, nonblocking
        match nix::fcntl::flock(h.as_raw_fd(), nix::fcntl::FlockArg::LockExclusiveNonblock) {
            // if the lock would block, another process is listening
            Err(nix::Error::Sys(nix::errno::EWOULDBLOCK)) => {
                Err(BindError::OtherProcessListening(self.lockfile()))
            }
            other => other.map_err(BindError::Unix),
        }?;
        Ok(BindLock(h))
    }

    /// The absolute path of the socket.
    pub fn path(&self) -> &Path {
        self.0.as_ref()
    }

    /// The Unix socket address of this socket.
    pub fn address(&self) -> String {
        format!("unix:{}", self.0.display())
    }

    fn lockfile(&self) -> PathBuf {
        self.0.with_file_name({
            let mut s = self
                .0
                .file_name()
                .unwrap_or_else(|| panic!("Socket file ({:?}) must end in a file name", self.0))
                .to_owned();
            s.push(".lock");
            s
        })
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn lock_is_exclusive() {
        let tempdir = tempfile::tempdir().unwrap();
        let p = tempdir.path().join("socket");
        let _lock = SocketPath(p.clone())
            .lock()
            .expect("first locking attempt should succeed");
        assert!(
            SocketPath(p).lock().is_err(),
            "second locking attempt should fail because we still hold the lock"
        );
    }
}
