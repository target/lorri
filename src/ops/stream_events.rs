//! Run to output a stream of build events in a machine-parseable form.
use crate::build_loop::Event;
use crate::ops;
use crate::ops::error::{ok, ExitError, OpResult};
use crate::socket::{
    communicate::client::{self, Error},
    path::SocketPath,
    ReadError, ReadWriteError, Timeout,
};
use std::str::FromStr;

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

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(kind: EventKind) -> OpResult {
    let events = client::stream_events(Timeout::Infinite)
        .connect(&SocketPath::from(ops::get_paths()?.daemon_socket_file()))
        .map_err(|e| ExitError::temporary(format!("connecting to daemon: {:?}", e)))?;

    let mut snapshot_done = false;

    loop {
        match events.read() {
            Ok(Event::SectionEnd) => {
                debug!("SectionEnd");
                if let EventKind::Snapshot = kind {
                    return ok();
                } else {
                    snapshot_done = true
                }
            }
            Ok(ev) => match (snapshot_done, &kind) {
                (_, EventKind::All) | (false, EventKind::Snapshot) | (true, EventKind::Live) => {
                    println!(
                        "{}",
                        serde_json::to_string(&ev).expect("couldn't serialize event")
                    )
                }
                _ => (),
            },
            Err(Error::Message(ReadWriteError::R(ReadError::Timeout))) => {
                return Err(ExitError::temporary("Server appears to have quit"));
            }
            Err(Error::Message(ReadWriteError::R(ReadError::Deserialize(_)))) => {
                return Err(ExitError::temporary("Socket closed unexpectedly"));
            }
            otherwise => {
                debug!("some other error!");
                return Err(ExitError::panic(format!("{:?}", otherwise)));
            }
        }
    }
}
