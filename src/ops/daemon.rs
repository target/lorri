//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.

use crate::daemon::Daemon;
use crate::ops::error::{ok, OpResult};
use crate::socket::SocketPath;
use crate::thread::Pool;
use slog_scope::info;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main() -> OpResult {
    let paths = crate::ops::get_paths()?;
    let socket_path = SocketPath::from(paths.daemon_socket_file());
    let (mut daemon, server, build_rx, accept_rx) = Daemon::try_new(socket_path)?;

    let mut pool = Pool::new();
    pool.spawn("accept-loop", move || {
        server
            .serve()
            .expect("failed to serve daemon server endpoint");
    })
    .expect("Failed to spawn accept-loop");

    pool.spawn("build-loop", || {
        for msg in build_rx {
            info!("build status"; "message" => ?msg);
        }
    })
    .expect("Failed to spawn build-loop");

    info!("ready");

    pool.spawn("build-instruction-handler", move || {
        // For each build instruction, add the corresponding file
        // to the watch list.
        for start_build in accept_rx {
            let project = crate::project::Project::new(
                start_build.nix_file,
                paths.gc_root_dir(),
                paths.cas_store().clone(),
            )
            // TODO: the project needs to create its gc root dir
            .unwrap();
            daemon.add(project)
        }
    })
    .expect("failed to spawn build-instruction-handler");

    pool.join_all_or_panic();

    ok()
}
