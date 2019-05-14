//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::ops::{ok, OpResult};

use std::path::Path;

use crate::socket::communicate::listener::Listener;
use crate::socket::communicate::{CommunicationType, NoMessage, Ping};
use crate::socket::{ReadError, ReadWriter};

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main() -> OpResult {
    // TODO: set up socket path, make it settable by the user
    let handle = Listener::new(Path::new("/tmp/lorri-socket"))
        .unwrap()
        .accept(|unix_stream, comm_type| match comm_type {
            CommunicationType::Ping => ping(ReadWriter::new(unix_stream)),
        })
        .unwrap();

    handle.join().unwrap();

    ok()
}

/// Handle the ping
// the ReadWriter here has to be the inverse of the `Client.ping()`, which is `ReadWriter<!, Ping>`
fn ping(rw: ReadWriter<Ping, NoMessage>) {
    let ping: Result<Ping, ReadError> = rw.read(None);
    match ping {
        Err(e) => eprintln!("didn’t receive a ping!! {:?}", e),
        Ok(p) => eprintln!("pinged with {}", p.nix_file.display()),
    }
}
