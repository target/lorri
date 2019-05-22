//! Talking to the `lorri` daemon / unix sockets.

pub mod communicate;

use std::io::Write;
use std::marker::PhantomData;
use std::os::unix::net::UnixStream;
use std::time::{Duration, Instant};

/// Wrapper around a socket that can send and receive structured messages.
///
/// `timeout` arguments set the socket timeout before reading/writing.
/// `None` means no timeout.
pub struct ReadWriter<'a, R, W> {
    // where R: serde::Deserialize {
    socket: &'a UnixStream,
    phantom_r: PhantomData<R>,
    phantom_w: PhantomData<W>,
}

/// A (possible) timeout
#[derive(Clone)]
pub enum Timeout {
    /// do not time out
    Infinite,
    /// Time out after `Duration`
    D(Duration),
}

impl Timeout {
    /// Convert to a timeout understood by `UnixStream`s
    fn to_socket_timeout(&self) -> Option<Duration> {
        match self {
            Timeout::Infinite => None,
            // Socket timeout must not be 0 (or it crashes).
            // instead, use a very short duration
            Timeout::D(d) => Some(if d == &Duration::new(0, 0) {
                Duration::from_millis(1)
            } else {
                *d
            }),
        }
    }
}

/// Reading from a `ReadWriter<'a, R, W>` failed.
#[derive(Debug)]
pub enum ReadError {
    /// Deserializing `R` failed.
    Deserialize(bincode::Error),
    /// No value available within given timeout.
    Timeout,
}

// TODO: combine with ReadError?
/// Writing to a `ReadWriter<'a, R, W>` failed.
#[derive(Debug)]
pub enum WriteError {
    /// Serializing `W` failed.
    Serialize(bincode::Error),
    /// No value available within given timeout.
    Timeout,
}

impl From<bincode::Error> for WriteError {
    fn from(e: bincode::Error) -> WriteError {
        WriteError::Serialize(e)
    }
}

/// Reading from or writing to a `ReadWriter<'a, R, W>` failed.
#[derive(Debug)]
pub enum ReadWriteError {
    /// Reading failed.
    R(ReadError),
    /// Writing failed.
    W(WriteError),
}

impl From<ReadError> for ReadWriteError {
    fn from(r: ReadError) -> Self {
        ReadWriteError::R(r)
    }
}
impl From<WriteError> for ReadWriteError {
    fn from(r: WriteError) -> Self {
        ReadWriteError::W(r)
    }
}

// put into the Io part of a `bincode::ErrorKind`
fn into_bincode_io_error<T>(res: std::io::Result<T>) -> bincode::Result<T> {
    res.map_err(|e| Box::new(bincode::ErrorKind::Io(e)))
}

/// Run action with a timeout, return the remaining timeout
/// or `Err` if there’s no time remaining.
///
/// The interface is not very “rusty”, but it’s only used internally.
fn with_timeout<F, A>(timeout: Timeout, action: F) -> Result<(Timeout, A), ()>
where
    F: FnOnce(&Timeout) -> A,
{
    // start a timer
    let i = Instant::now();
    // run the action with the full timeout
    let res = action(&timeout);
    match timeout {
        Timeout::Infinite => Ok((Timeout::Infinite, res)),
        Timeout::D(d) => match d.checked_sub(i.elapsed()) {
            // no time remaining
            None => Err(()),
            // return a new timeout with remaining time
            Some(d2) => Ok((Timeout::D(d2), res)),
        },
    }
}

impl<'a, R, W> ReadWriter<'a, R, W> {
    // TODO: &mut UnixStream
    /// Create from a unix socket.
    pub fn new(socket: &'a UnixStream) -> ReadWriter<'a, R, W> {
        ReadWriter {
            socket,
            phantom_r: PhantomData,
            phantom_w: PhantomData,
        }
    }

    /// Send a message to the other side and wait for a reply.
    /// The timeout counts for the whole roundtrip.
    pub fn communicate(&mut self, timeout: Timeout, mes: &W) -> Result<R, ReadWriteError>
    where
        R: serde::de::DeserializeOwned,
        W: serde::Serialize,
    {
        let (timeout, write) =
            with_timeout(timeout, |t| self.write(t, mes)).map_err(|()| WriteError::Timeout)?;
        write?;
        let e = self.read(&timeout)?;
        Ok(e)
    }

    /// Check if the underlying socket timed out when serializing/deserilizing.
    fn is_timed_out(e: &bincode::ErrorKind) -> bool {
        match e {
            bincode::ErrorKind::Io(io) => match io.kind() {
                std::io::ErrorKind::TimedOut => true,
                _ => false,
            },
            _ => false,
        }
    }

    /// Wait for a message to arrive.
    pub fn read(&self, timeout: &Timeout) -> Result<R, ReadError>
    where
        R: serde::de::DeserializeOwned,
    {
        into_bincode_io_error(self.socket.set_read_timeout(timeout.to_socket_timeout()))
            .map_err(ReadError::Deserialize)?;

        // XXX: “If this returns an Error, `reader` may be in an invalid state”.
        // what the heck does that mean.
        bincode::deserialize_from(self.socket).map_err(|e| {
            if Self::is_timed_out(&e) {
                ReadError::Timeout
            } else {
                ReadError::Deserialize(e)
            }
        })
    }

    /// Send a message to the other side.
    pub fn write(&mut self, timeout: &Timeout, mes: &W) -> Result<(), WriteError>
    where
        W: serde::Serialize,
    {
        into_bincode_io_error(self.socket.set_write_timeout(timeout.to_socket_timeout()))?;

        bincode::serialize_into(self.socket, mes).map_err(|e| {
            if Self::is_timed_out(&e) {
                WriteError::Timeout
            } else {
                WriteError::Serialize(e)
            }
        })?;

        into_bincode_io_error(self.socket.flush())?;

        Ok(())
    }
}
