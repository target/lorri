//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.

use crate::build_loop::Event;
use crate::cli::DaemonOptions;
use crate::daemon::Daemon;
use crate::ops::{ok, ExitError, OpResult};
use crate::socket::communicate::listener;
use crate::socket::communicate::CommunicationType;
use crate::socket::ReadWriter;
use crate::thread::Pool;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc;
use std::sync::Arc;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(opts: DaemonOptions) -> OpResult {
    let paths = crate::ops::get_paths()?;
    let daemon_socket_file = paths.daemon_socket_file().to_owned();
    let socket_path = ::socket::path::SocketPath::from(&daemon_socket_file);
    // TODO: move listener into Daemon struct?
    let listener = listener::Listener::new(&socket_path).map_err(|e| match e {
        ::socket::path::BindError::OtherProcessListening => ExitError::errmsg(format!(
            "Another daemon is already listening on the socket at {}. \
             We are currently only allowing one daemon to be running at the same time.",
            socket_path.display()
        )),
        e => panic!("{:?}", e),
    })?;

    let (mut daemon, build_messages_rx) = Daemon::new();

    // messages sent from accept handlers
    let (accept_messages_tx, accept_messages_rx) = mpsc::channel();

    // coordinate single-shot build
    let cont = Arc::new(AtomicBool::new(true));
    let once = opts.once;

    let handlers = daemon.handlers();

    let mut pool = Pool::new();
    pool.spawn("accept-loop", move || {
        while cont.load(Ordering::SeqCst) {
            // Cloning required because of the closure.
            let accept_messages_tx = accept_messages_tx.clone();
            let cont = cont.clone();
            let handlers = handlers.clone();
            let _handle = listener
                .accept(move |unix_stream, comm_type| match comm_type {
                    CommunicationType::Ping => {
                        handlers.ping(ReadWriter::new(&unix_stream), accept_messages_tx);
                        if once {
                            cont.store(false, Ordering::SeqCst);
                        }
                    }
                })
                // TODO
                .unwrap();
        }
    })
    .expect("Failed to spawn accept-loop");

    pool.spawn("build-loop", move || {
        for msg in build_messages_rx {
            println!("{:#?}", msg);
            if once {
                match msg {
                    Event::Started => {}
                    Event::Completed(_) | Event::Failure(_) => break,
                }
            }
        }
    })
    .expect("Failed to spawn build-loop");

    println!("lorri: ready");

    pool.spawn("build-instruction-handler", move || {
        // For each build instruction, add the corresponding file
        // to the watch list.
        for start_build in accept_messages_rx {
            let project = ::project::Project::new(
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
