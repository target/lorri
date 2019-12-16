//! The daemon's RPC server.

use super::IndicateActivity;
use crate::ops::error::ExitError;
use crate::rpc;
use crate::socket::{BindLock, SocketPath};
use crate::NixFile;
use crossbeam_channel as chan;
use std::convert::TryFrom;
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
        let initial_worker_threads = 1;
        let max_worker_threads = 1;
        let idle_timeout = 0;
        varlink::listen(
            service,
            address,
            initial_worker_threads,
            max_worker_threads,
            idle_timeout,
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
        match NixFile::try_from(shell_nix) {
            Ok(nix_file) => {
                self.activity_tx
                    .send(IndicateActivity { nix_file })
                    .expect("failed to indicate activity via channel");
                call.reply()
            }
            Err(e) => call.reply_invalid_parameter(e),
        }
    }
}

impl std::convert::TryFrom<&NixFile> for rpc::ShellNix {
    type Error = &'static str;

    fn try_from(nix_file: &NixFile) -> Result<Self, Self::Error> {
        match PathBuf::from(nix_file).as_os_str().to_str() {
            Some(s) => Ok(rpc::ShellNix {
                path: s.to_string(),
            }),
            None => Err("nix file path is not UTF-8 clean"),
        }
    }
}

impl std::convert::TryFrom<rpc::ShellNix> for NixFile {
    type Error = String;

    fn try_from(shell_nix: rpc::ShellNix) -> Result<Self, Self::Error> {
        let path = PathBuf::from(shell_nix.path);
        if path.as_path().is_file() {
            Ok(NixFile::Shell(path))
        } else {
            Err(format!("nix file {} does not exist", path.display()))
        }
    }
}
