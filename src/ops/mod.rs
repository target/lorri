//! Ops are command-line callables.

pub mod daemon;
pub mod direnv;
pub mod info;
pub mod init;
pub mod ping;
pub mod upgrade;
pub mod watch;

/// Set up necessary directories or fail.
pub fn get_paths() -> Result<::constants::Paths, ExitError> {
    ::constants::Paths::initialize()
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
        ExitError::err(1, message.into())
    }

    /// Helpers to create exit results
    ///
    /// Note: err panics if exitcode is zero.
    fn err<T>(exitcode: i32, message: T) -> ExitError
    where
        T: Into<String>,
    {
        assert!(exitcode != 0, "ExitError exitcode must be > 0!");

        ExitError {
            exitcode,
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

#[cfg(test)]
mod tests {
    use super::ExitError;

    #[test]
    #[should_panic]
    fn err_requires_nonzero() {
        ExitError::err(0, "bogus");
    }

    #[test]
    fn getters() {
        match ExitError::err(1, "bogus") {
            e => {
                assert_eq!(e.exitcode(), 1);
                assert_eq!(e.message(), "bogus");
            }
        }
    }
}
