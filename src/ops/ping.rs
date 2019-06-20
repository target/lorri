//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::ops::{ok, OpResult};
use crate::NixFile;

use crate::socket::communicate::client;
use crate::socket::communicate::{Ping, DEFAULT_READ_TIMEOUT};

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(nix_file: NixFile) -> OpResult {
    // TODO: set up socket path, make it settable by the user
    client::ping(DEFAULT_READ_TIMEOUT)
        // TODO
        .connect(&::socket::path::SocketPath::from(
            ::ops::get_paths()?.daemon_socket_file(),
        ))
        .unwrap()
        .write(&Ping { nix_file })
        .unwrap();
    ok()
}
