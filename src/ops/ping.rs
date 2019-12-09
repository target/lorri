//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::ops::error::{ok, OpResult};
use crate::rpc;
use crate::NixFile;

/// See the documentation for lorri::cli::Command::Ping_ for details.
pub fn main(nix_file: NixFile) -> OpResult {
    // TODO: set up socket path, make it settable by the user
    let address = crate::ops::get_paths()?.daemon_socket_address();
    let shell_nix = rpc::ShellNix {
        path: nix_file.to_string(),
    };

    use rpc::VarlinkClientInterface;
    rpc::VarlinkClient::new(
        varlink::Connection::with_address(&address).expect("failed to connect to daemon server"),
    )
    .watch_shell(shell_nix)
    .call()
    .expect("call to daemon server failed");
    ok()
}
