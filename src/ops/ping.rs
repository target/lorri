//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::ops::{ok, OpResult};

use std::path::{Path, PathBuf};

use crate::socket::communicate::client;
use crate::socket::communicate::Ping;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(nix_file: PathBuf) -> OpResult {
    // TODO: set up socket path, make it settable by the user
    client::ping(None)
        // TODO
        .connect(Path::new("/tmp/lorri-socket"))
        .unwrap()
        .write(&Ping { nix_file })
        .unwrap();
    ok()
}
