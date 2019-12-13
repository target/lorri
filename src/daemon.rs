//! The lorri daemon, watches multiple projects in the background.

use crate::build_loop::BuildLoop;
use crate::ops::error::ExitError;
use crate::project::Project;
use crate::socket::SocketPath;
use crate::NixFile;
use crossbeam_channel as chan;
use std::collections::HashMap;
use std::path::PathBuf;

mod rpc;

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

struct Handler {
    tx: chan::Sender<()>,
    _handle: std::thread::JoinHandle<()>,
}

/// Keeps all state of the running `lorri daemon` service, watches nix files and runs builds.
pub struct Daemon {
    /// A thread for each `BuildLoop`, keyed by the nix files listened on.
    handler_threads: HashMap<NixFile, Handler>,
    /// Sending end that we pass to every `BuildLoop` the daemon controls.
    // TODO: this needs to transmit information to identify the builder with
    build_tx: chan::Sender<crate::build_loop::Event>,
}

impl Daemon {
    /// Create a new daemon. Also return an `chan::Receiver` that
    /// receives `build_loop::Event`s for all builders this daemon
    /// supervises.
    pub fn new() -> (Daemon, chan::Receiver<crate::build_loop::Event>) {
        let (build_tx, build_rx) = chan::unbounded();
        (
            Daemon {
                handler_threads: HashMap::new(),
                build_tx,
            },
            build_rx,
        )
    }

    /// Serve the daemon's RPC endpoint.
    pub fn serve(
        mut self,
        socket_path: SocketPath,
        gc_root_dir: PathBuf,
        cas: crate::cas::ContentAddressable,
    ) -> Result<(), ExitError> {
        let (activity_tx, activity_rx) = chan::unbounded();
        let server = rpc::Server::new(socket_path, activity_tx)?;
        let mut pool = crate::thread::Pool::new();
        pool.spawn("accept-loop", move || {
            server
                .serve()
                .expect("failed to serve daemon server endpoint");
        })?;
        pool.spawn("build-instruction-handler", move || {
            // For each build instruction, add the corresponding file
            // to the watch list.
            for start_build in activity_rx {
                let project =
                    crate::project::Project::new(start_build.nix_file, &gc_root_dir, cas.clone())
                        // TODO: the project needs to create its gc root dir
                        .unwrap();
                self.add(project)
            }
        })?;
        pool.join_all_or_panic();

        Ok(())
    }

    /// Add nix file to the set of files this daemon watches
    /// & build if they change.
    pub fn add(&mut self, project: Project) {
        let (tx, rx) = chan::unbounded();
        let build_tx = self.build_tx.clone();

        self.handler_threads
            .entry(project.shell_nix.clone())
            .or_insert_with(|| Handler {
                tx,
                _handle: std::thread::spawn(move || {
                    let mut build_loop = BuildLoop::new(&project);

                    // cloning the tx means the daemon’s rx gets all
                    // messages from all builders.
                    build_loop.forever(build_tx, rx);
                }),
            })
            // Notify the handler, whether or not it was newly added
            .tx
            .send(())
            .unwrap();
    }
}
