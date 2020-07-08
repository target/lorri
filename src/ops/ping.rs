//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::internal_proto;
use crate::ops::error::{ok, OpResult};
use crate::NixFile;
use std::convert::TryFrom;

/// See the documentation for lorri::cli::Command::Ping_ for details.
pub fn main(nix_file: NixFile, addr: Option<String>) -> OpResult {
    let address = match addr {
        Some(a) => a,
        None => crate::ops::get_paths()?.daemon_socket_address()
    };
    let shell_nix = internal_proto::ShellNix::try_from(&nix_file).unwrap();

    use internal_proto::VarlinkClientInterface;
    internal_proto::VarlinkClient::new(
        varlink::Connection::with_address(&address).expect("failed to connect to daemon server"),
    )
    .watch_shell(shell_nix)
    .call()
    .expect("call to daemon server failed");
    ok()
}
