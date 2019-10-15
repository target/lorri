//! Communication with the lorri daemon.
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

use crate::socket::path::{BindError, BindLock, SocketPath};
use crate::socket::{ReadWriteError, ReadWriter, Timeout};
use crate::NixFile;

/// We declare 1s as the time readers should wait
/// for the other side to send something.
pub const DEFAULT_READ_TIMEOUT: Timeout = Timeout::from_millis(1000);

/// Enum of all communication modes the lorri daemon supports.
#[derive(Serialize, Deserialize)]
pub enum CommunicationType {
    /// Ping the daemon from a project to tell it to watch & evaluate
    // TODO: rename to IndicateActivity (along with all other `ping` things)
    // issue: https://github.com/target/lorri/issues/101
    Ping,
}

/// Message sent by the client to ask the server to start
/// watching `nix_file`. See `CommunicationType::Ping`.
#[derive(Serialize, Deserialize)]
pub struct Ping {
    /// The nix file to watch and build on changes.
    pub nix_file: NixFile,
}

/// No message can be sent through this socket end (empty type).
pub enum NoMessage {}

/// `Listener` and possible errors.
pub mod listener {
    use super::*;
    use std::os::unix::net::{UnixListener, UnixStream};

    /// If a connection on the socket is attempted and the first
    /// message is of a `ConnectionType`, the `Listener` returns
    /// this message as an ack.
    /// In all other cases the `Listener` returns no answer (the
    /// bad client should time out after some time).
    #[derive(Debug, Serialize, Deserialize)]
    pub struct ConnectionAccepted();

    /// Server-side part of a socket transmission,
    /// listening for incoming messages.
    pub struct Listener {
        /// Bound Unix socket.
        listener: UnixListener,
        /// Lock that keeps our socket exclusive.
        // `bind_lock` is never actually used anywhere,
        // it is released when `Listener`’s lifetime ends.
        // We can ignore the “dead code” warning.
        #[allow(dead_code)]
        bind_lock: BindLock,
        /// How long to wait for the client to send its
        /// first message after opening the connection.
        accept_timeout: Timeout,
    }

    /// Errors in `accept()`ing a new connection.
    #[derive(Debug)]
    pub enum AcceptError {
        /// something went wrong in the `accept()` syscall.
        Accept(std::io::Error),
        /// The client’s message could not be decoded.
        Message(ReadWriteError),
    }

    impl Listener {
        /// Create a new `daemon` by binding to `socket_path`.
        pub fn new(socket_path: &SocketPath) -> Result<Listener, BindError> {
            let (l, lock) = socket_path.bind()?;
            Ok(Listener {
                listener: l,
                bind_lock: lock,
                accept_timeout: DEFAULT_READ_TIMEOUT,
            })
        }

        /// Accept a new connection on the socket,
        /// read the communication type and then delegate to the
        /// corresponding handling subroutine.
        ///
        /// The handler is start in a thread, the thread handle is returned.
        ///
        /// This method blocks until a client tries to connect.
        pub fn accept<F: 'static>(
            &self,
            handler: F,
        ) -> Result<std::thread::JoinHandle<()>, AcceptError>
        where
            F: FnOnce(UnixStream, CommunicationType) -> (),
            F: std::marker::Send,
        {
            // - socket accept
            let (unix_stream, _) = self.listener.accept().map_err(AcceptError::Accept)?;
            // - read first message as a `CommunicationType`
            let comm_type: CommunicationType =
                ReadWriter::<CommunicationType, ConnectionAccepted>::new(&unix_stream)
                    .react(self.accept_timeout.clone(), |_| ConnectionAccepted())
                    .map_err(AcceptError::Message)?;
            // spawn a thread with the accept handler
            Ok(std::thread::spawn(move || handler(unix_stream, comm_type)))
        }
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
    use std::marker::PhantomData;

    /// A `Client` that can talk to a `Listener`.
    pub struct Client<R, W> {
        /// Type of interaction with the `Listener`.
        comm_type: CommunicationType,
        /// Connected socket.
        socket: Option<UnixStream>,
        /// Timeout for reads/writes.
        timeout: Timeout,
        read_type: PhantomData<R>,
        write_type: PhantomData<W>,
    }

    /// Error when talking to the `Listener`.
    #[derive(Debug)]
    pub enum Error {
        /// Not connected to the `Listener` socket.
        NotConnected,
        /// Read error or write error.
        Message(ReadWriteError),
    }

    /// Error when initializing connection with the `Listener`.
    #[derive(Debug)]
    pub enum InitError {
        /// `connect()` syscall failed.
        SocketConnect(std::io::Error),
        /// Handshake failed (write `ConnectionType`, read `ConnectionAccepted`).
        ServerHandshake(ReadWriteError),
    }

    // builder pattern for timeouts?

    impl<R, W> Client<R, W> {
        /// “Bake” a Client, aka set its communication type (and message type arguments).
        /// Not exported.
        fn bake(timeout: Timeout, comm_type: CommunicationType) -> Client<R, W> {
            Client {
                comm_type,
                socket: None,
                timeout,
                read_type: PhantomData,
                write_type: PhantomData,
            }
        }

        /// Connect to the `Listener` listening on `socket_path`.
        pub fn connect(self, socket_path: &SocketPath) -> Result<Client<R, W>, InitError> {
            // TODO: check if the file exists and is a socket

            // - connect to `socket_path`
            let socket = socket_path.connect().map_err(InitError::SocketConnect)?;

            // - send initial message with the CommunicationType
            // - wait for server to acknowledge connect
            let _: listener::ConnectionAccepted = ReadWriter::new(&socket)
                .communicate(self.timeout.clone(), &self.comm_type)
                .map_err(InitError::ServerHandshake)?;

            Ok(Client {
                comm_type: self.comm_type,
                socket: Some(socket),
                timeout: self.timeout,
                read_type: PhantomData,
                write_type: PhantomData,
            })
        }

        /// Read a message returned by the connected `Listener`.
        pub fn read(self) -> Result<R, Error>
        where
            R: serde::de::DeserializeOwned,
        {
            let sock = &self.socket.ok_or(Error::NotConnected)?;
            let rw: ReadWriter<R, W> = ReadWriter::new(sock);
            rw.read(&self.timeout)
                .map_err(|e| Error::Message(ReadWriteError::R(e)))
        }

        /// Write a message to the connected `Listener`.
        pub fn write(self, mes: &W) -> Result<(), Error>
        where
            W: serde::Serialize,
        {
            let sock = &self.socket.ok_or(Error::NotConnected)?;
            let mut rw: ReadWriter<R, W> = ReadWriter::new(sock);
            rw.write(&self.timeout, mes)
                .map_err(|e| Error::Message(ReadWriteError::W(e)))
        }
    }

    /// Client for the `Ping` communication type.
    /// Reading and writing messages is bounded by `timeout`.
    pub fn ping(timeout: Timeout) -> Client<NoMessage, Ping> {
        Client::bake(timeout, CommunicationType::Ping)
    }
}
