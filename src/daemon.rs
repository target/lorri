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
    handlers: HashMap<NixFile, std::thread::JoinHandle<()>>,
    /// Sending end that we pass to every `BuildLoop` the daemon controls.
    // TODO: this needs to transmit information to identify the builder with
    build_events_tx: mpsc::Sender<::build_loop::Event>,
    /// Static paths the daemon has access to.
    paths: &'a ::constants::Paths,
}

impl<'a> Daemon<'a> {
    /// Create a new daemon. Also return an `mpsc::Receiver` that
    /// receives `build_loop::Event`s for all builders this daemon
    /// supervises.
    pub fn new(paths: &'a ::constants::Paths) -> (Daemon<'a>, mpsc::Receiver<::build_loop::Event>) {
        let (tx, rx) = mpsc::channel();
        (
            Daemon {
                handlers: HashMap::new(),
                build_events_tx: tx,
                paths,
            },
            rx,
        )
    }

    /// Add nix file to the set of files this daemon watches
    /// & build if they change.
    pub fn add(&mut self, nix_file: NixFile) {
        let tx = self.build_events_tx.clone();
        let root_dir = self.paths.gc_root_dir().to_owned();

        self.handlers.entry(nix_file.clone()).or_insert_with(|| {
            // TODO: refactor Project/Roots stuff, a little bit too complicated
            // TODO: all these clones are not needed
            let project = Project::load(nix_file.clone(), root_dir).unwrap();
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

/// Accept handler for `socket::communicate::Ping` messages.
/// For a valid ping message, it sends an instruction to start
/// the build to `build_chan`.
// TODO: make private again
// the ReadWriter here has to be the inverse of the `Client.ping()`, which is `ReadWriter<!, Ping>`
pub fn ping(rw: ReadWriter<Ping, NoMessage>, build_chan: mpsc::Sender<StartBuild>) {
    // TODO: read timeout
    let ping: Result<Ping, ReadError> = rw.read(&Timeout::Infinite);
    match ping {
        Err(e) => debug!("didn’t receive a ping!! {:?}", e),
        Ok(p) => {
            eprintln!("pinged with {}", p.nix_file);
            build_chan
                .send(StartBuild {
                    nix_file: p.nix_file,
                })
                .expect("StartBuild channel closed")
        }
    }
}
