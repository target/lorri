//! The lorri daemon, watches multiple projects in the background.

use crate::build_loop::BuildLoop;
use crate::project::Project;
use crate::roots::Roots;
use crate::socket::communicate::{NoMessage, Ping};
use crate::socket::{ReadError, ReadWriter, Timeout};
use crate::NixFile;
use std::collections::HashMap;
use std::sync::mpsc;

/// Instructs the daemon to start a build.
pub struct StartBuild {
    /// The nix file to watch and build on changes.
    pub nix_file: NixFile,
}

/// Keeps all state of the running `lorri daemon` service, watches nix files and runs builds.
pub struct Daemon<'a> {
    /// A thread for each `BuildLoop`, keyed by the nix files listened on.
    handler_threads: HashMap<NixFile, std::thread::JoinHandle<()>>,
    /// Sending end that we pass to every `BuildLoop` the daemon controls.
    // TODO: this needs to transmit information to identify the builder with
    build_events_tx: mpsc::Sender<::build_loop::Event>,
    /// Static paths the daemon has access to.
    paths: &'a ::constants::Paths,
    /// The handlers functions for incoming requests
    handler_fns: HandlerFns,
}

// TODO: set a `Listener` up in the daemon instead of manually outside

impl<'a> Daemon<'a> {
    /// Create a new daemon. Also return an `mpsc::Receiver` that
    /// receives `build_loop::Event`s for all builders this daemon
    /// supervises.
    pub fn new(paths: &'a ::constants::Paths) -> (Daemon<'a>, mpsc::Receiver<::build_loop::Event>) {
        let (tx, rx) = mpsc::channel();
        (
            Daemon {
                handler_threads: HashMap::new(),
                build_events_tx: tx,
                paths,
                handler_fns: HandlerFns {
                    // We just declare 1s as timeout time, which should be more than enough
                    read_timeout: Timeout::from_millis(1000),
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
    pub fn add(&mut self, nix_file: NixFile) {
        let tx = self.build_events_tx.clone();
        let root_dir = self.paths.gc_root_dir().to_owned();

        self.handler_threads
            .entry(nix_file.clone())
            .or_insert_with(|| {
                // We construct a Project here for each dependency we get.
                let project = Project::new(&nix_file, &root_dir);
                // TODO unwrap
                let roots = Roots::from_project(&project).unwrap();
                let mut build_loop = BuildLoop::new(nix_file.clone(), roots);

                std::thread::spawn(move || {
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
    pub fn ping(&self, rw: ReadWriter<Ping, NoMessage>, build_chan: mpsc::Sender<StartBuild>) {
        // TODO: read timeout
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
                    .send(StartBuild {
                        nix_file: p.nix_file,
                    })
                    .expect("StartBuild channel closed")
            }
        }
    }
}
