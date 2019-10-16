//! Run to output a stream of build events in a machine-parseable form.
use crate::ops::{OpResult,err_msg};
use crate::build_loop::Event;
use crate::socket::{ReadWriteError, ReadError};
use crate::socket::communicate::client::{self,Error};
use crate::socket::communicate::DEFAULT_READ_TIMEOUT;

/// See the documentation for lorri::cli::Command::Shell for more
/// details.
pub fn main() -> OpResult {
    let events = client::stream_events(DEFAULT_READ_TIMEOUT)
        .connect(&::socket::path::SocketPath::from(
            ::ops::get_paths()?.daemon_socket_file(),
        ))
        .expect("trying to open socket to daemon");

    loop {
        match events.read() {
            Ok(Event::Heartbeat) => debug!("heartbeat received"),
            Ok(ev) => {
                println!("{}", serde_json::to_string(&ev).expect("couldn't serialize event"))
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
