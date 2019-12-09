//! The daemon's RPC server.

use super::IndicateActivity;
use crate::ops::error::ExitError;
use crate::rpc;
use crate::socket::{BindLock, SocketPath};
use crate::NixFile;
use crossbeam_channel as chan;
use std::path::PathBuf;

/// The daemon server.
pub struct Server {
    activity_tx: chan::Sender<IndicateActivity>,
    socket_path: SocketPath,
    _lock: BindLock,
}

impl Server {
    /// Create a new Server. Locks the Unix socket path, so there can be only one Server instance
    /// per socket path at any time.
    pub fn new(
        socket_path: SocketPath,
        activity_tx: chan::Sender<IndicateActivity>,
    ) -> Result<Server, ExitError> {
        let lock = socket_path.lock()?;
        Ok(Server {
            socket_path,
            activity_tx,
            _lock: lock,
        })
    }

    /// Serve the daemon endpoint.
    pub fn serve(self) -> Result<(), ExitError> {
        let address = &self.socket_path.address();
        let service = varlink::VarlinkService::new(
            /* vendor */ "com.target",
            /* product */ "lorri",
            /* version */ "0.1",
            /* url */ "https://github.com/target/lorri",
            vec![Box::new(rpc::new(Box::new(self)))],
        );
        varlink::listen(
            service, address, /* initial_worker_threads */ 1, /* max_worker_threads */ 1,
            /* idle_timeout */ 0,
        )
        .map_err(|e| ExitError::temporary(format!("{}", e)))
    }
}

/// The actual varlink server implementation. See com.target.lorri.varlink for the interface
/// specification.
impl rpc::VarlinkInterface for Server {
    fn watch_shell(
        &self,
        call: &mut dyn rpc::Call_WatchShell,
        shell_nix: rpc::ShellNix,
    ) -> varlink::Result<()> {
        let path = PathBuf::from(shell_nix.path);
        if !path.as_path().is_file() {
            return call.reply_invalid_parameter(format!("'{}' is not a file", path.display()));
        }
        self.activity_tx
            .send(IndicateActivity {
                nix_file: NixFile::from(path),
            })
            .expect("failed to indicate activity via channel");
        call.reply()
    }
}
