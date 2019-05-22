//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::build_loop::{self, BuildLoop};
use crate::ops::{ok, OpResult};
use crate::project::Project;
use crate::roots::Roots;
use crate::socket::communicate::listener;
use crate::socket::communicate::{CommunicationType, NoMessage, Ping};
use crate::socket::{ReadError, ReadWriter};
use std::collections::HashMap;
use std::path::Path;
use std::path::PathBuf;
use std::sync::mpsc;
use std::thread;

const SOCKET_FILE_NAME: &str = "/tmp/lorri-socket";

// TODO: make private again
/// Instructs the daemon to start a build
pub struct StartBuild {
    /// The nix file to watch and build on changes.
    pub nix_file: PathBuf,
}

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main() -> OpResult {
    let socket_path = Path::new(SOCKET_FILE_NAME);
    // TODO: move listener into Daemon struct?
    let listener = listener::Listener::new(socket_path)
        // TODO
        .unwrap();
    // TODO: set up socket path, make it settable by the user
    let (mut daemon, build_messages_rx) = Daemon::new();

    // messages sent from accept handlers
    let (accept_messages_tx, accept_messages_rx) = mpsc::channel();

    // TODO join handle
    let _accept_loop_handle = thread::spawn(move || loop {
        let accept_messages_tx = accept_messages_tx.clone();
        let _handle = listener
            .accept(|unix_stream, comm_type| match comm_type {
                CommunicationType::Ping => ping(ReadWriter::new(&unix_stream), accept_messages_tx),
            })
            // TODO
            .unwrap();
    });

    // TODO: join handle
    let _start_build_loop_handle = thread::spawn(|| {
        for msg in build_messages_rx {
            println!("{:#?}", msg);
        }
    });

    // For each build instruction, add the corresponding file
    // to the watch list.
    for start_build in accept_messages_rx {
        daemon.add(start_build.nix_file)
    }

    ok()

    // TODO: join all accept handles & accept_loop_handle
    // handle.join().unwrap();
}

// TODO: move from ops to internals
/// Keeps all state of the running `lorri daemon` service.
pub struct Daemon {
    // TODO: PathBuf is a nix file
    handlers: HashMap<PathBuf, std::thread::JoinHandle<()>>,
    build_events_tx: mpsc::Sender<build_loop::Event>,
}

impl Daemon {
    /// Create a new daemon. Also return an `mpsc::Receiver` that
    /// receives `build_loop::Event`s for all builders this daemon
    /// supervises.
    pub fn new() -> (Daemon, mpsc::Receiver<build_loop::Event>) {
        let (tx, rx) = mpsc::channel();
        (
            Daemon {
                handlers: HashMap::new(),
                build_events_tx: tx,
            },
            rx,
        )
    }

    /// Add nix file to the set of files this daemon watches
    /// & builds if they change.
    pub fn add(&mut self, nix_file: PathBuf) {
        let tx = self.build_events_tx.clone();

        self.handlers.entry(nix_file.clone()).or_insert_with(|| {
            // TODO: refactor Project/Roots stuff, a little bit too complicated
            // TODO: all these clones are not needed
            let project = Project::load(nix_file.clone(), Project::default_gc_root_dir()).unwrap();
            // TODO
            let roots = Roots::from_project(&project).unwrap();
            let mut build_loop = BuildLoop::new(nix_file.clone(), roots);

            thread::spawn(move || {
                // cloning the tx means the daemon’s rx gets all
                // messages from all builders.
                build_loop.forever(tx);
            })
        });
    }
}

/// Accept handler for `socket::communicate::Ping` messages.
/// For a valid ping message, it sends an instruction to start
/// the build to `build_chan`.
// TODO: make private again
// the ReadWriter here has to be the inverse of the `Client.ping()`, which is `ReadWriter<!, Ping>`
pub fn ping(rw: ReadWriter<Ping, NoMessage>, build_chan: mpsc::Sender<StartBuild>) {
    // TODO: read timeout
    let ping: Result<Ping, ReadError> = rw.read(None);
    match ping {
        Err(e) => eprintln!("didn’t receive a ping!! {:?}", e),
        Ok(p) => {
            eprintln!("pinged with {}", p.nix_file.display());
            build_chan
                .send(StartBuild {
                    nix_file: p.nix_file,
                })
                .expect("StartBuild channel closed")
        }
    }
}
