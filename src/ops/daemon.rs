//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.

use crate::daemon::Daemon;
use crate::ops::error::{ok, OpResult};
use crate::socket::SocketPath;
use slog_scope::info;

/// See the documentation for lorri::cli::Command::Daemon for details.
pub fn main() -> OpResult {
    let (daemon, build_rx) = Daemon::new();
    let build_handle = std::thread::spawn(|| {
        for msg in build_rx {
            info!("build status"; "message" => ?msg);
        }
    });
    info!("ready");

    let paths = crate::ops::get_paths()?;
    daemon.serve(
        SocketPath::from(paths.daemon_socket_file()),
        paths.gc_root_dir().to_path_buf(),
        paths.cas_store().clone(),
    )?;
    build_handle
        .join()
        .expect("failed to join build status thread");
    ok()
}
