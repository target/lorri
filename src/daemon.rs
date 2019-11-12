//! The lorri daemon, watches multiple projects in the background.

use crate::build_loop::BuildLoop;
use crate::project::Project;
use crate::socket::communicate::{NoMessage, Ping, DEFAULT_READ_TIMEOUT};
use crate::socket::{ReadError, ReadWriter, Timeout};
use crate::NixFile;
use std::collections::HashMap;
use std::sync::mpsc;

/// Indicate that the user is interested in a specific nix file.
/// Usually a nix file describes the environment of a project,
/// so the user editor would send this message when a file
/// in the project is opened, through `lorri direnv` for example.
///
/// `lorri ping_` is the plumbing command which triggers this signal.
///
/// Note especially that we don’t want to fix the server reaction to
/// this signal yet, sending `IndicateActivity` does not necessarily
/// start a build immediately (or at all, if for example we implement
/// a “pause/stop” functionality). The semantics will be specified
/// at a later time.
pub struct IndicateActivity {
    /// This nix file should be build/watched by the daemon.
    pub nix_file: NixFile,
}

/// Keeps all state of the running `lorri daemon` service, watches nix files and runs builds.
pub struct Daemon {
    /// A thread for each `BuildLoop`, keyed by the nix files listened on.
    handler_threads: HashMap<NixFile, std::thread::JoinHandle<()>>,
    /// Sending end that we pass to every `BuildLoop` the daemon controls.
    // TODO: this needs to transmit information to identify the builder with
    build_events_tx: mpsc::Sender<crate::build_loop::Event>,
    /// The handlers functions for incoming requests
    handler_fns: HandlerFns,
}

// TODO: set a `Listener` up in the daemon instead of manually outside

impl Daemon {
    /// Create a new daemon. Also return an `mpsc::Receiver` that
    /// receives `build_loop::Event`s for all builders this daemon
    /// supervises.
    pub fn new() -> (Daemon, mpsc::Receiver<crate::build_loop::Event>) {
        let (tx, rx) = mpsc::channel();
        (
            Daemon {
                handler_threads: HashMap::new(),
                build_events_tx: tx,
                handler_fns: HandlerFns {
                    read_timeout: DEFAULT_READ_TIMEOUT,
                },
            },
            rx,
        )
    }

    /// The handler daemon message handler functions
    pub fn handlers(&self) -> HandlerFns {
        self.handler_fns.clone()
    }

    /// Add nix file to the set of files this daemon watches
    /// & build if they change.
    pub fn add(&mut self, project: Project) {
        let tx = self.build_events_tx.clone();

        self.handler_threads
            .entry(project.nix_file.clone())
            .or_insert_with(|| {
                std::thread::spawn(move || {
                    let mut build_loop = BuildLoop::new(&project);

                    // cloning the tx means the daemon’s rx gets all
                    // messages from all builders.
                    build_loop.forever(tx);
                })
            });
    }
}

/// Holds handler functions the daemon uses to react to messages.
#[derive(Clone)]
pub struct HandlerFns {
    /// How long the daemon waits for messages to arrive after accept()
    read_timeout: Timeout,
}

impl HandlerFns {
    /// Accept handler for `socket::communicate::Ping` messages.
    /// For a valid ping message, it sends an instruction to start
    /// the build to `build_chan`.
    // TODO: make private again
    // the ReadWriter here has to be the inverse of the `Client.ping()`, which is `ReadWriter<!, Ping>`
    pub fn ping(
        &self,
        rw: ReadWriter<Ping, NoMessage>,
        build_chan: mpsc::Sender<IndicateActivity>,
    ) {
        let ping: Result<Ping, ReadError> = rw.read(&self.read_timeout);
        match ping {
            Err(ReadError::Timeout) => debug!(
                "Client didn’t send a `Ping` message after waiting for {}",
                &self.read_timeout
            ),
            Err(ReadError::Deserialize(e)) => {
                debug!("Client `Ping` message could not be decoded: {}", e)
            }
            Ok(p) => {
                info!("pinged with {}", p.nix_file);
                build_chan
                    .send(IndicateActivity {
                        nix_file: p.nix_file,
                    })
                    .expect("StartBuild channel closed")
            }
        }
    }
}
