//! Ops are command-line callables.

pub mod daemon;
pub mod direnv;
pub mod info;
pub mod init;
pub mod ping;
pub mod upgrade;
pub mod watch;

/// Set up necessary directories or fail.
pub fn get_paths() -> Result<crate::constants::Paths, ExitError> {
    crate::constants::Paths::initialize()
        .map_err(|e| ExitError::errmsg(format!("Cannot initialize the lorri paths: {:#?}", e,)))
}

/// Non-zero exit status from an op
#[derive(Debug, Clone)]
pub struct ExitError {
    /// Exit code of the process, should be non-zero
    exitcode: i32,

    /// Final dying words
    message: String,
}

/// Final result from a CLI operation
pub type OpResult = Result<Option<String>, ExitError>;

/// Return an OpResult with a final message to print before exit 0
/// Note, the final message is possibly intended to be consumed
/// by automated tests.
pub fn ok_msg<T>(message: T) -> OpResult
where
    T: Into<String>,
{
    Ok(Some(message.into()))
}

/// Return an OpResult with no message to be printed, producing
/// a silent exit 0
pub fn ok() -> OpResult {
    Ok(None)
}

impl ExitError {
    /// Exit 1 with an exit message
    pub fn errmsg<T>(message: T) -> ExitError
    where
        T: Into<String>,
    {
        ExitError {
            exitcode: 1,
            message: message.into(),
        }
    }

    /// Exit 100 to signify an unexpected crash (lorri bug).
    pub fn unrecoverable<T>(message: T) -> ExitError
    where
        T: Into<String>,
    {
        ExitError {
            exitcode: 100,
            message: message.into(),
        }
    }

    /// Exit code of the failure message, guaranteed to be > 0
    pub fn exitcode(&self) -> i32 {
        self.exitcode
    }

    /// Exit message to be displayed to the user on stderr
    pub fn message(&self) -> &str {
        &self.message
    }
}
