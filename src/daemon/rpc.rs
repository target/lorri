//! The daemon's RPC server.

use super::IndicateActivity;
use super::LoopHandlerEvent;
use crate::build_loop::Event;
use crate::ops::error::ExitError;
use crate::rpc;
use crate::socket::{BindLock, SocketPath};
use crate::watch;
use crate::NixFile;
use crossbeam_channel as chan;
use std::convert::TryFrom;
use std::path::PathBuf;

/// The daemon server.
pub struct Server {
    activity_tx: chan::Sender<IndicateActivity>,
    build_tx: chan::Sender<LoopHandlerEvent>,
    socket_path: SocketPath,
    _lock: BindLock,
}

impl Server {
    /// Create a new Server. Locks the Unix socket path, so there can be only one Server instance
    /// per socket path at any time.
    pub fn new(
        socket_path: SocketPath,
        activity_tx: chan::Sender<IndicateActivity>,
        build_tx: chan::Sender<LoopHandlerEvent>,
    ) -> Result<Server, ExitError> {
        let lock = socket_path.lock()?;
        Ok(Server {
            socket_path,
            activity_tx,
            build_tx,
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

    fn monitor(&self, call: &mut dyn rpc::Call_Monitor) -> varlink::Result<()> {
        if !call.wants_more() {
            return call.reply_invalid_parameter("wants_more".into());
        }

        let (tx, rx) = chan::unbounded();
        self.build_tx
            .send(LoopHandlerEvent::NewListener(tx))
            .map_err(|_| varlink::error::ErrorKind::Server)?;

        call.set_continues(true);
        for event in rx {
            match event.try_into() {
                Ok(ev) => call.reply(ev),
                Err(e) => call.reply_invalid_parameter(e.to_string()),
            }?;
        }
        Ok(())
    }
}

use std::convert::TryInto;

impl TryFrom<&Event> for rpc::Event {
    type Error = &'static str;

    fn try_from(ev: &Event) -> Result<Self, Self::Error> {
        use rpc::Event_kind as kind;
        Ok(match ev {
            Event::SectionEnd => rpc::Event {
                kind: kind::sectionend,
                nix_file: None,
                reason: None,
                result: None,
                failure: None,
            },
            Event::Started { nix_file, reason } => rpc::Event {
                kind: kind::started,
                nix_file: Some(nix_file.try_into()?),
                reason: Some(reason.try_into()?),
                result: None,
                failure: None,
            },
            Event::Completed { nix_file, result } => rpc::Event {
                kind: kind::completed,
                nix_file: Some(nix_file.try_into()?),
                reason: None,
                result: Some(result.try_into()?),
                failure: None,
            },
            Event::Failure { nix_file, failure } => rpc::Event {
                kind: kind::failure,
                nix_file: Some(nix_file.try_into()?),
                reason: None,
                result: None,
                failure: Some(failure.try_into()?),
            },
        })
    }
}

impl TryFrom<Event> for rpc::Event {
    type Error = &'static str;

    fn try_from(ev: Event) -> Result<Self, Self::Error> {
        rpc::Event::try_from(&ev)
    }
}

impl TryFrom<rpc::Monitor_Reply> for Event {
    type Error = String;

    fn try_from(mr: rpc::Monitor_Reply) -> Result<Self, Self::Error> {
        Event::try_from(mr.event)
    }
}

impl TryFrom<rpc::Event> for Event {
    type Error = String;

    fn try_from(re: rpc::Event) -> Result<Self, Self::Error> {
        use rpc::Event_kind::*;

        Ok(match re.kind {
            sectionend => Event::SectionEnd,
            started => Event::Started {
                nix_file: re.nix_file.ok_or("missing nix file!")?.try_into()?,
                reason: re.reason.ok_or("missing reason!")?.try_into()?,
            },
            completed => Event::Completed {
                nix_file: re.nix_file.ok_or("missing nix file!")?.try_into()?,
                result: re.result.ok_or("missing result!")?.into(),
            },
            failure => Event::Failure {
                nix_file: re.nix_file.ok_or("missing nix file!")?.try_into()?,
                failure: re.failure.ok_or("missing failure log")?.into(),
            },
        })
    }
}

impl TryFrom<&watch::Reason> for rpc::Reason {
    type Error = &'static str;

    fn try_from(wr: &watch::Reason) -> Result<Self, Self::Error> {
        use rpc::Reason_kind::*;
        use watch::Reason;

        Ok(match wr {
            Reason::PingReceived => rpc::Reason {
                kind: pingreceived,
                project: None,
                files: None,
                debug: None,
            },
            Reason::ProjectAdded(project) => rpc::Reason {
                kind: projectadded,
                project: Some(rpc::ShellNix::try_from(project)?),
                files: None,
                debug: None,
            },
            Reason::FilesChanged(changed) => rpc::Reason {
                kind: fileschanged,
                project: None,
                files: Some(
                    changed
                        .into_iter()
                        .map(|pb| Ok(pb.to_str().ok_or("cannot convert path!")?.to_string()))
                        .collect::<Result<Vec<String>, &'static str>>()?,
                ),
                debug: None,
            },
            Reason::UnknownEvent(dbg) => rpc::Reason {
                kind: pingreceived,
                project: None,
                files: None,
                debug: Some(dbg.into()),
            },
        })
    }
}

impl TryFrom<rpc::Reason> for watch::Reason {
    type Error = String;

    fn try_from(rr: rpc::Reason) -> Result<Self, Self::Error> {
        use rpc::Reason_kind::*;
        use watch::Reason;

        Ok(match rr.kind {
            pingreceived => Reason::PingReceived,
            projectadded => {
                Reason::ProjectAdded(rr.project.ok_or("missing nix file!")?.try_into()?)
            }
            fileschanged => Reason::FilesChanged(
                rr.files
                    .ok_or("missing files!")?
                    .into_iter()
                    .map(|s| s.into())
                    .collect(),
            ),
            unknown => Reason::UnknownEvent(rr.debug.ok_or("missing debug string!")?.into()),
        })
    }
}

use crate::build_loop;

impl TryFrom<&build_loop::BuildResults> for rpc::Outcome {
    type Error = &'static str;

    fn try_from(br: &build_loop::BuildResults) -> Result<Self, Self::Error> {
        Ok(rpc::Outcome {
            project_root: br
                .output_paths
                .shell_gc_root
                .as_os_str()
                .to_str()
                .ok_or("cannot convert gc root to string")?
                .to_string(),
        })
    }
}

impl From<rpc::Outcome> for build_loop::BuildResults {
    fn from(ro: rpc::Outcome) -> Self {
        use crate::build_loop::BuildResults;
        use crate::builder::OutputPaths;
        use crate::project::roots::RootPath;

        BuildResults {
            output_paths: OutputPaths {
                shell_gc_root: RootPath(ro.project_root.into()),
            },
        }
    }
}

impl TryFrom<&build_loop::BuildExitFailure> for rpc::Failure {
    type Error = &'static str;
    fn try_from(bef: &build_loop::BuildExitFailure) -> Result<Self, Self::Error> {
        Ok(rpc::Failure {
            log: bef
                .log_lines
                .clone()
                .into_iter()
                .map(|l| {
                    let os: std::ffi::OsString = l.into();
                    Ok(os
                        .to_str()
                        .ok_or("cannot convert log line into string")?
                        .to_string())
                })
                .collect::<Result<Vec<String>, &'static str>>()?,
        })
    }
}

impl From<rpc::Failure> for build_loop::BuildExitFailure {
    fn from(rf: rpc::Failure) -> Self {
        use std::ffi::OsString;

        build_loop::BuildExitFailure {
            log_lines: rf
                .log
                .into_iter()
                .map(|l| {
                    let oss: OsString = l.into();
                    build_loop::LogLine::from(oss)
                })
                .collect(),
        }
    }
}

impl TryFrom<&NixFile> for rpc::ShellNix {
    type Error = &'static str;

    fn try_from(nix_file: &NixFile) -> Result<Self, Self::Error> {
        match nix_file {
            NixFile::Shell(shell) => match shell.as_os_str().to_str() {
                Some(s) => Ok(rpc::ShellNix {
                    path: s.to_string(),
                }),
                None => Err("nix file path is not UTF-8 clean"),
            },
            NixFile::Services(_) => Err("need a shell nix file, not a services nix file"),
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
