extern crate lorri;
extern crate tempfile;

use lorri::build_loop;
use lorri::cas::ContentAddressable;
use lorri::daemon::Daemon;
use lorri::project::Project;
use lorri::rpc;
use lorri::socket::SocketPath;
use std::io::{Error, ErrorKind};
use std::thread;
use std::time::{Duration, Instant};

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

    let tempdir = tempfile::tempdir()?;
    let shell_nix = tempdir.as_ref().join("shell.nix");
    std::fs::File::create(&shell_nix)?;

    // create unix socket file
    let p = &tempdir.path().join("socket");
    let socket_path = SocketPath::from(p);
    let address = socket_path.address();

    // The daemon knows how to build stuff
    let (mut daemon, server, build_rx, accept_rx) = Daemon::try_new(socket_path).unwrap();

    // listen for incoming messages
    let accept_handle = thread::spawn(move || {
        server.serve().unwrap();
    });

    // connect to socket and send a ping message
    use crate::lorri::rpc::VarlinkClientInterface;
    rpc::VarlinkClient::new(connect(&address, Duration::from_millis(1000)))
        .watch_shell(rpc::ShellNix {
            path: shell_nix.to_str().unwrap().to_string(),
        })
        .call()
        .unwrap();

    // The client pinged, so now a message should have arrived
    let start_build = accept_rx.recv_timeout(Duration::from_millis(100)).unwrap();

    let cas = ContentAddressable::new(tempdir.path().join("cas")).unwrap();
    let project = Project::new(start_build.nix_file, &tempdir.path().join("gc_root"), cas).unwrap();
    daemon.add(project);

    // Read the first build event, which should be a `Started` message
    match build_rx.recv_timeout(Duration::from_millis(100)).unwrap() {
        build_loop::Event::Started(_) => Ok(()),
        ev => Err(Error::new(
            ErrorKind::Other,
            format!("didn’t expect event {:?}", ev),
        )),
    }?;

    drop(accept_handle);
    drop(tempdir);
    Ok(())
}

/// The server side of the connection is started in a separate thread. This function waits until
/// the socket address is available for connection.
fn connect(
    address: &str,
    timeout: Duration,
) -> std::sync::Arc<std::sync::RwLock<varlink::Connection>> {
    use varlink::error::{Error, ErrorKind};

    let start = Instant::now();
    let mut connection = None;
    while connection.is_none() {
        if start.elapsed() > timeout {
            panic!("failed to connect to RPC endpoint within {:?}", timeout);
        }
        match varlink::Connection::with_address(&address) {
            Err(Error(ErrorKind::Io(std::io::ErrorKind::NotFound), _, _)) => (),
            Ok(c) => connection = Some(c),
            Err(e) => panic!("unexpected error: {}", e),
        }
    }
    connection.unwrap()
}
