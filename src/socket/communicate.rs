//! Communication with the `lorri` daemon.
//!
//! We provide a fixed number of `CommunicationType`s that are sent
//! between the lorri daemon and lorri clients wishing to connect to it.
//!
//! `listener` implements the daemon side, which provides an `accept`
//! method which is similar to how `accept()` works on a plain Unix socket.
//!
//! `client` implements a set of clients specialized to the communications
//! we support.

use std::os::unix::net::UnixStream;

use crate::socket::{ReadError, ReadWriteError, ReadWriter, Timeout};

/// Enum of all communication modes the lorri daemon supports.
#[derive(Serialize, Deserialize)]
pub enum CommunicationType {
    /// Ping the daemon from a project to tell it to watch & evaluate
    Ping,
}

/// Message sent by the client to ask the server to start
/// watching `nix_file`. See `CommunicationType::Ping`.
pub struct Ping {
    /// The nix file to watch and build on changes.
    nix_file: String,
}

/// No message can be sent through this socket end (empty type).
pub enum NoMessage {}

/// `Listener` and possible errors.
pub mod listener {
    use super::*;
    use std::io::Write;
    use std::os::unix::net::{UnixListener, UnixStream};
    use std::path::Path;

    /// If a connection on the socket is attempted and the first
    /// message is of a `ConnectionType`, the `Listener` returns
    /// this message as an ack.
    /// In all other cases the `Listener` returns no answer (the
    /// bad client should time out after some time).
    #[derive(Serialize, Deserialize)]
    pub struct ConnectionAccepted();

    /// Server-side part of a socket transmission,
    /// listening for incoming messages.
    pub struct Listener {
        /// Bound Unix socket.
        listener: UnixListener,
        /// How long to wait for the client to send its
        /// first message after opening the connection.
        accept_timeout: Timeout,
    }

    /// Errors in `accept()`ing a new connection.
    pub enum AcceptError {
        /// something went wrong in the `accept()` syscall.
        Accept(std::io::Error),
        /// The client’s message could not be decoded.
        Message(ReadError),
    }

    /// Binding to the socket failed.
    pub struct BindError(std::io::Error);

    impl Listener {
        /// Create a new `daemon` by binding to `socket_path`.
        fn new(socket_path: &Path) -> Result<Listener, BindError> {
            Ok(Listener {
                listener: UnixListener::bind(socket_path).map_err(BindError)?,
                // TODO: set some timeout?
                accept_timeout: None,
            })
        }

        /// Accept a new connection on the socket,
        /// read the communication type and then delegate to the
        /// corresponding handling subroutine.
        pub fn accept<F: 'static>(
            self,
            handler: F,
        ) -> Result<std::thread::JoinHandle<()>, AcceptError>
        where
            F: FnOnce(UnixStream, CommunicationType) -> (),
            F: std::marker::Send,
        {
            // - socket accept
            let (mut unix_stream, _) = self.listener.accept().map_err(AcceptError::Accept)?;
            // - read first message as a `CommunicationType`
            // TODO: move to this
            // let commType: CommunicationType = ReadWriter::<CommunicationType, ConnectionAccepted>::new(unixStream)
            //     .react(self.accept_timeout, |commType| -> ConnectionAccepted())
            //     .map_err(AcceptError::Message)?;
            let comm_type: CommunicationType = bincode::deserialize_from(&unix_stream)
                .map_err(|e| AcceptError::Message(ReadError::Deserialize(e)))?;
            bincode::serialize_into(&unix_stream, &ConnectionAccepted())
                // TODO WriteError
                .map_err(|e| AcceptError::Message(ReadError::Deserialize(e)))?;
            unix_stream.flush().map_err(AcceptError::Accept)?;
            // spawn a thread with the accept handler
            Ok(std::thread::spawn(move || handler(unix_stream, comm_type)))
        }
    }

    /// Handle the ping event
    // the ReadWriter here has to be the inverse of the `Client.ping()`, which is `ReadWriter<!, Ping>`
    pub fn ping(rw: ReadWriter<Ping, NoMessage>) {
        // tx.send(rw.read())
    }

}

/// Clients that can talk to a `Listener`.
///
/// `R` is the type of messages this client reads.
/// `W` is the type of messages this client writes.
///
/// The construction of `Client` is only exported for
/// the pre-defined interactions with the `Listener` we support.
pub mod client {
    use super::*;
    use std::path::Path;

    /// A `Client` that can talk to a `Listener`.
    pub struct Client<R, W> {
        /// Type of interaction with the `Listener`.
        comm_type: CommunicationType,
        /// Connected socket.
        rw: Option<ReadWriter<R, W>>,
        /// Timeout for reads/writes.
        timeout: Timeout,
    }

    /// Error when talking to the `Listener`.
    pub enum Error {
        /// Not connected to the `Listener` socket.
        NotConnected,
        /// Read error or write error.
        Message(ReadWriteError),
    }

    /// Error when initializing connection with the `Listener`.
    pub enum InitError {
        /// `connect()` syscall failed.
        SocketConnect(std::io::Error),
        /// Handshake failed (write `ConnectionType`, read `ConnectionAccepted`).
        ServerHandshake(ReadWriteError),
    }

    // TODO: builder pattern for timeouts?

    impl<R, W> Client<R, W> {
        /// “Bake” a Client, aka set its communication type (and message type arguments).
        /// Not exported.
        fn bake(timeout: Timeout, comm_type: CommunicationType) -> Client<R, W> {
            Client {
                comm_type,
                rw: None,
                timeout,
            }
        }

        /// Connect to the `Listener` listening on `socket_path`.
        pub fn connect(self, socket_path: &Path) -> Result<Client<R, W>, InitError> {
            // TODO: check if the file exists and is a socket
            // - connect to `socket_path`
            let socket = UnixStream::connect(socket_path).map_err(InitError::SocketConnect)?;
            // - send initial message with the CommunicationType
            // - wait for server to acknowledge connect
            let _: listener::ConnectionAccepted = ReadWriter::new(socket)
                .communicate(self.timeout, &self.comm_type)
                .map_err(InitError::ServerHandshake)?;
            Ok(self)
        }

        /// Read a message returned by the connected `Listener`.
        pub fn read(self) -> Result<R, Error>
        where
            R: serde::de::DeserializeOwned,
        {
            self.rw
                .ok_or(Error::NotConnected)?
                .read(self.timeout)
                .map_err(|e| Error::Message(ReadWriteError::R(e)))
        }

        /// Write a message to the connected `Listener`.
        pub fn write(self, mes: &W) -> Result<(), Error>
        where
            W: serde::Serialize,
        {
            self.rw
                .ok_or(Error::NotConnected)?
                .write(self.timeout, mes)
                .map_err(|e| Error::Message(ReadWriteError::W(e)))
        }
    }

    /// Client for the `Ping` communication type.
    /// Reading and writing messages is bounded by `timeout`.
    pub fn ping(timeout: Timeout) -> Client<NoMessage, Ping> {
        Client::bake(timeout, CommunicationType::Ping)
    }

}
