//! `bind()`ing & `connect()`ing to sockets.

extern crate nix;

use std::os::unix::io::AsRawFd;
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::{Path, PathBuf};

/// Small wrapper that makes sure lorri sockets are handled correctly.
pub struct SocketPath<'a>(&'a Path);

/// Binding to the socket failed.
#[derive(Debug)]
pub enum BindError {
    /// Another process is listening on the socket
    OtherProcessListening,
    /// I/O error
    Io(std::io::Error),
    /// nix library I/O error (like Io)
    Unix(nix::Error),
}

impl From<std::io::Error> for BindError {
    fn from(e: std::io::Error) -> BindError {
        BindError::Io(e)
    }
}

/// Locks the socket the server is bound to. Drop to release.
pub struct BindLock(std::fs::File);

impl<'a> SocketPath<'a> {
    /// Create from the path of the socket.
    /// Must be passed a valid socket file path (ending in a file name).
    pub fn from(socket_path: &Path) -> SocketPath {
        SocketPath(socket_path)
    }

    /// Display the underlying `Path`.
    pub fn display(&self) -> std::path::Display {
        self.0.display()
    }

    /// Return lockfile path.
    pub fn lockfile(&self) -> PathBuf {
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

    /// Try to lock the lock file to find outswhether another process is listening.
    fn try_locking(&self) -> Result<BindLock, BindError> {
        let h = std::fs::OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(self.lockfile())?;
        // we try to get an exclusive lock, nonblocking
        match nix::fcntl::flock(h.as_raw_fd(), nix::fcntl::FlockArg::LockExclusiveNonblock) {
            // if the lock would block, another process is listening
            Err(nix::Error::Sys(nix::errno::EWOULDBLOCK)) => Err(BindError::OtherProcessListening),
            other => other.map_err(BindError::Unix),
        }?;
        Ok(BindLock(h))
    }

    /// `bind(2)` to this socket path.
    ///
    /// Uses a lock file to guarantee no other process is listening to the same socket.
    /// The lock file is the socket file with a `.lock` file ending appended.
    ///
    /// The lock file is released automatically when the returned `BindLock` is dropped.
    ///
    /// Uses the `flock(2)` trick decribed in
    /// https://gavv.github.io/articles/unix-socket-reuse/
    pub fn bind(&self) -> Result<(UnixListener, BindLock), BindError> {
        // - try to lock lockfile (open and flock exclusive nonblocking)
        let lock = self.try_locking()?;
        // - remove socket file if it exists
        std::fs::remove_file(self.0).or_else(|e| {
            if e.kind() == std::io::ErrorKind::NotFound {
                Ok(())
            } else {
                Err(e)
            }
        })?;
        // - bind to socket
        let l = UnixListener::bind(self.0)?;
        Ok((l, lock))
    }

    /// `connect(2)` to this socket path.
    pub fn connect(&self) -> std::io::Result<UnixStream> {
        UnixStream::connect(self.0)
    }
}
