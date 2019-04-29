//! Talking to the `lorri` daemon / unix sockets.

use std::io::Write;
use std::marker::PhantomData;
use std::os::unix::net::UnixStream;
use std::time::{Duration, Instant};

/// Wrapper around a socket that can send and receive structured messages.
///
/// `timeout` arguments set the socket timeout before reading/writing.
/// `None` means no timeout.
pub struct ReadWriter<R, W> {
    // where R: serde::Deserialize {
    socket: UnixStream,
    phantom_r: PhantomData<R>,
    phantom_w: PhantomData<W>,
}

/// A timeout. `None` means forever.
pub type Timeout = Option<Duration>;

/// Reading from a `ReadWriter<R, W>` failed.
pub enum ReadError {
    /// Deserializing `R` failed.
    Deserialize(bincode::Error),
    /// No value available within given timeout.
    Timeout,
}

// TODO: combine with ReadError?
/// Writing to a `ReadWriter<R, W>` failed.
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

/// Reading from or writing to a `ReadWriter<R, W>` failed.
pub enum ReadWriteError {
    /// Reading failed.
    R(ReadError),
    /// Writing failed.
    W(WriteError),
}

// put into the Io part of a `bincode::ErrorKind`
fn into_bincode_io_error<T>(res: std::io::Result<T>) -> bincode::Result<T> {
    res.map_err(|e| Box::new(bincode::ErrorKind::Io(e)))
}

impl<R, W> ReadWriter<R, W> {
    /// Create from a unix socket.
    pub fn new(socket: UnixStream) -> ReadWriter<R, W> {
        ReadWriter {
            socket,
            phantom_r: PhantomData,
            phantom_w: PhantomData,
        }
    }

    // socket timeout must not be 0 (or it crashes)
    fn sanitize_timeout(timeout: Timeout) -> Timeout {
        timeout.filter(|d| d != &Duration::new(0, 0))
    }

    /// Send a message to the other side and wait for a reply.
    /// The timeout counts for the whole roundtrip.
    pub fn communicate(&self, timeout: Timeout, mes: &W) -> Result<R, ReadWriteError>
    where
        R: serde::de::DeserializeOwned,
        W: serde::Serialize,
    {
        let i = Instant::now();
        self.write(timeout, mes).map_err(ReadWriteError::W)?;
        // remove the passede from timeout
        let new_timeout = timeout.and_then(|d| d.checked_sub(i.elapsed()));
        self.read(new_timeout).map_err(ReadWriteError::R)
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
    pub fn read(&self, timeout: Timeout) -> Result<R, ReadError>
    where
        R: serde::de::DeserializeOwned,
    {
        into_bincode_io_error(
            self.socket
                .set_read_timeout(Self::sanitize_timeout(timeout)),
        )
        .map_err(ReadError::Deserialize)?;

        // XXX: “If this returns an Error, `reader` may be in an invalid state”.
        // what the heck does that mean.
        bincode::deserialize_from(&self.socket).map_err(|e| {
            if Self::is_timed_out(&e) {
                ReadError::Timeout
            } else {
                ReadError::Deserialize(e)
            }
        })
    }

    /// Send a message to the other side.
    pub fn write(&self, timeout: Timeout, mes: &W) -> Result<(), WriteError>
    where
        W: serde::Serialize,
    {
        into_bincode_io_error(
            self.socket
                .set_write_timeout(Self::sanitize_timeout(timeout)),
        )?;

        bincode::serialize_into(&self.socket, mes).map_err(|e| {
            if Self::is_timed_out(&e) {
                WriteError::Timeout
            } else {
                WriteError::Serialize(e)
            }
        })?;

        into_bincode_io_error((&self.socket).flush())?;

        Ok(())
    }
}
