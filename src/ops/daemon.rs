//! Run a BuildLoop for `shell.nix`, watching for input file changes.
//! Can be used together with `direnv`.
use crate::daemon::Daemon;
use crate::ops::{ok, ExitError, OpResult};
use crate::socket::communicate::listener;
use crate::socket::communicate::CommunicationType;
use crate::socket::ReadWriter;
use std::sync::mpsc;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main() -> OpResult {
    let paths = ::ops::get_paths()?;
    let socket_path = ::socket::path::SocketPath::from(paths.daemon_socket_file());
    // TODO: move listener into Daemon struct?
    let listener = listener::Listener::new(&socket_path).map_err(|e| match e {
        ::socket::path::BindError::OtherProcessListening => ExitError::errmsg(format!(
            "Another daemon is already listening on the socket at {}. \
             We are currently only allowing one daemon to be running at the same time.",
            socket_path.display()
        )),
        e => panic!("{:?}", e),
    })?;

    // The daemon sends back build messages from its various build loops
    let (mut daemon, build_messages_rx) = Daemon::new();

    // messages sent from the (unix socket) accept handler
    let (accept_messages_tx, accept_messages_rx) = mpsc::channel();

    // threads don’t throw their panics to the main thread,
    // so we need to catch unrecoverable stuff manually
    let (panic_button_tx, panic_button_rx) = mpsc::channel();

    let handlers = daemon.handlers();

    // TODO join handle
    let _accept_loop_handle = std::thread::spawn(move || loop {
        let accept_messages_tx = accept_messages_tx.clone();
        // has to clone handlers once per accept loop,
        // because accept spawns a thread each time.
        let handlers = handlers.clone();
        let _handle = listener
            .accept(move |unix_stream, comm_type| match comm_type {
                CommunicationType::Ping => {
                    handlers.ping(ReadWriter::new(&unix_stream), accept_messages_tx)
                }
            })
            // TODO
            .unwrap();
    });

    // TODO: join handle
    let _start_build_loop_handle = std::thread::spawn(move || {
        for msg in build_messages_rx {
            match msg {
                Ok(m) => println!("{:#?}", m),
                // This is the case where a builder catches an unexpected error
                // and we have to crash.
                // TODO: add human-message to get a nice stack & link for people to open an issue
                Err(unrecoverable) => panic_button_tx
                    .send(format!(
                        "An unrecoverable error has occured. Please open an issue!\n{:#?}",
                        unrecoverable
                    ))
                    .unwrap(),
            }
        }
    });

    println!("lorri: ready");

    // For each build instruction, add the corresponding file
    // to the watch list.
    let gc_root_dir = paths.gc_root_dir().to_owned();
    let cas_store = paths.cas_store().to_owned();
    let _add_project_daemon_handle = std::thread::spawn(move || {
        for start_build in accept_messages_rx {
            let project =
                ::project::Project::new(start_build.nix_file, &gc_root_dir, cas_store.clone())
                    // TODO: the project needs to create its gc root dir
                    .unwrap();
            daemon.add(project)
        }
    });

    // if any unrecoverable error is received from a build thread, panic.
    for panic in panic_button_rx {
        panic!(panic);
    }

    ok()

    // TODO: join all accept handles & accept_loop_handle
    // handle.join().unwrap();
}
