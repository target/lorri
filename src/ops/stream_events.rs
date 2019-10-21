//! Run to output a stream of build events in a machine-parseable form.
use crate::ops::{OpResult,err_msg};
use crate::build_loop::Event;
use crate::socket::{ReadWriteError, ReadError};
use crate::socket::communicate::client::{self,Error};
use crate::socket::communicate::DEFAULT_READ_TIMEOUT;
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
            _ => Err(format!("{} not in all,live,snapshot", s))
        }
    }
}

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main(kind: EventKind) -> OpResult {
    let events = client::stream_events(DEFAULT_READ_TIMEOUT)
        .connect(&::socket::path::SocketPath::from(
            ::ops::get_paths()?.daemon_socket_file(),
        ))
        .expect("trying to open socket to daemon");

    let mut snapshot_done = false;

    loop {
        match events.read() {
            Ok(Event::Heartbeat) => debug!("heartbeat received"),
            Ok(Event::SectionEnd) => snapshot_done = true,
            Ok(ev) => {
                match (snapshot_done, &kind) {
                    (_, EventKind::All) | (false, EventKind::Snapshot) | (true, EventKind::Live) =>
                        println!("{}", serde_json::to_string(&ev).expect("couldn't serialize event")),
                    _ => ()
                }
            },
            Err(Error::Message(ReadWriteError::R(ReadError::Timeout))) => {
                return err_msg("Server appears to have quit");
            },
            Err(Error::Message(ReadWriteError::R(ReadError::Deserialize(_)))) => {
                return err_msg("Socket closed unexpectedly");
            },
            otherwise => {
                return err_msg(format!("{:?}", otherwise));
            }
        }
    }
}
