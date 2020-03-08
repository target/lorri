//! Run to output a stream of build events in a machine-parseable form.
use crate::ops::{
    error::{ok, ExitError, OpResult},
    get_paths,
};
use crate::rpc;
use crossbeam_channel::{select, unbounded};
use slog_scope::debug;
use std::convert::TryInto;
use std::str::FromStr;
use std::thread;
use std::time::Duration;

mod json_representation;
use json_representation::Event;

/// Options for the kinds of events to report
#[derive(Debug)]
pub enum EventKind {
    /// Report only live events - those that happen after invocation
    Live,
    /// Report events recorded for projects up until invocation
    Snapshot,
    /// Report all events
    All,
}

impl FromStr for EventKind {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "all" => Ok(EventKind::All),
            "live" => Ok(EventKind::Live),
            "snapshot" => Ok(EventKind::Snapshot),
            _ => Err(format!("{} not in all,live,snapshot", s)),
        }
    }
}

#[derive(Debug)]
enum Error {
    Varlink(rpc::Error),
    Compat(String),
}

/// See the documentation for lorri::cli::Command::StreamEvents_ for more
/// details.
pub fn main(kind: EventKind) -> OpResult {
    let address = get_paths()?.daemon_socket_address();

    use rpc::VarlinkClientInterface;
    let mut client = rpc::VarlinkClient::new(
        varlink::Connection::with_address(&address).expect("failed to connect to daemon server"),
    );

    let mut snapshot_done = false;
    let (tx, rx) = unbounded();
    let recycle = tx.clone();

    let th = thread::spawn(move || {
        for res in client.monitor().more().expect("couldn't connect to server") {
            tx.send(res).expect("local channel couldn't send")
        }
    });

    select! {
        recv(rx) -> event => recycle.send(event.expect("local channel couldn't receive")).expect("local channel couldn't resend"),
        default(Duration::from_millis(250)) => return Err(ExitError::temporary("server timeout"))
    }

    for event in rx.iter() {
        debug!("Received"; "event" => format!("{:#?}", &event));
        match event
            .map_err(Error::Varlink)
            .and_then(|ev| ev.try_into().map_err(Error::Compat))
            .map_err(|err| ExitError::temporary(format!("{:?}", err)))?
        {
            Event::SectionEnd => {
                debug!("SectionEnd");
                if let EventKind::Snapshot = kind {
                    return ok();
                } else {
                    snapshot_done = true
                }
            }
            ev => match (snapshot_done, &kind) {
                (_, EventKind::All) | (false, EventKind::Snapshot) | (true, EventKind::Live) => {
                    println!(
                        "{}",
                        serde_json::to_string(&ev).expect("couldn't serialize event")
                    )
                }
                _ => (),
            },
        }
    }

    drop(th);
    ok()
}
