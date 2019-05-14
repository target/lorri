extern crate lorri;
extern crate tempfile;

use lorri::build_loop;
use lorri::ops::daemon::Daemon;
use lorri::socket::communicate::{client, listener};
use lorri::socket::communicate::{CommunicationType, Ping};
use lorri::socket::ReadWriter;
use std::io::{Error, ErrorKind};
use std::path::PathBuf;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

/// This tests the basic working of the client/daemon setup.
///
/// The daemon starts listening, the client sends a message
/// to request watching a nix file, the daemon starts a `build_loop`
/// and the test is successful once the `build_loop` signals
/// that the build is starting up (`Event::Started`).
#[test]
pub fn start_job_with_ping() -> std::io::Result<()> {
    // TODO: this code is a mess because Daeomon is not
    // nicely abstracted yet.

    // messages returned by the `daemon.accept()` handler
    let (accept_messages_tx, accept_messages_rx) = mpsc::channel();

    let tempdir = tempfile::tempdir()?;
    let socket_file = tempdir.path().join("socket");

    // create unix socket file
    let listener = listener::Listener::new(&socket_file).unwrap();

    // listen for incoming messages
    // TODO: put this listener stuff into the Daemon
    let accept_handle = thread::spawn(move || {
        listener
            .accept(|unix_stream, comm_type| match comm_type {
                CommunicationType::Ping => {
                    lorri::ops::daemon::ping(ReadWriter::new(unix_stream), accept_messages_tx)
                }
            })
            .unwrap()
    });

    // The daemon knows how to build stuff
    let (mut daemon, build_events_rx) = Daemon::new();

    // connect to socket and send a ping message
    client::ping(None)
        .connect(&socket_file)
        .unwrap()
        .write(&Ping {
            nix_file: PathBuf::from("/who/cares"),
        })
        .unwrap();

    // The client pinged, so now a message should have arrived
    let daemon_subroutine_handle = accept_handle.join().unwrap();
    let start_build = accept_messages_rx
        .recv_timeout(Duration::from_millis(100))
        .unwrap();
    daemon.add(start_build.nix_file);

    // Read the first build event, which should be a `Started` message
    match build_events_rx
        .recv_timeout(Duration::from_millis(100))
        .unwrap()
    {
        build_loop::Event::Started => Ok(()),
        ev => Err(Error::new(
            ErrorKind::Other,
            format!("didn’t expect event {:?}", ev),
        )),
    }?;

    drop(tempdir);
    daemon_subroutine_handle.join().unwrap();
    Ok(())
}
