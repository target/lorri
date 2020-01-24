//! Ops are command-line callables.

pub mod daemon;
pub mod direnv;
pub mod info;
pub mod init;
pub mod ping;
pub mod shell;
pub mod upgrade;
pub mod watch;

/// Set up necessary directories or fail.
pub fn get_paths() -> Result<crate::constants::Paths, error::ExitError> {
    crate::constants::Paths::initialize().map_err(|e| {
        error::ExitError::user_error(format!("Cannot initialize the lorri paths: {:#?}", e))
    })
}

/// Error handling in ops.
pub mod error {

    /// Non-zero exit status from an op.
    ///
    /// Based in part on the execline convention
    /// (see https://skarnet.org/software/execline/exitcodes.html).
    ///
    /// All these commands exit
    /// - 1 if they encounter an expected error
    /// - 100 if they encounter a permanent error – “the user is holding it wrong”
    /// - 101 if they encounter a programming error, like a panic or failed assert
    /// - 111 if they encounter a temporary error, such as resource exhaustion
    /// - 126 if there is a problem with the environment in which lorri is run
    /// - 127 if they're trying to execute into a program and cannot find it
    #[derive(Debug, Clone)]
    pub struct ExitError {
        /// Exit code of the process, should be non-zero
        exitcode: i32,

        /// Final dying words
        message: String,
    }

    /// Final result from a CLI operation
    pub type OpResult = Result<(), ExitError>;

    /// Return an OpResult producing a silent exit 0
    pub fn ok() -> OpResult {
        Ok(())
    }

    impl ExitError {
        /// Exit 1 to signify a generic expected error
        /// (e.g. something that sometimes just goes wrong, like a nix build).
        pub fn expected_error<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 1,
                message: message.into(),
            }
        }

        /// Exit 100 to signify a user error (“the user is holding it wrong”).
        /// This is a permanent error, if the program is executed the same way
        /// it should crash with 100 again.
        pub fn user_error<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 100,
                message: message.into(),
            }
        }

        /// Exit 101 to signify an unexpected crash (failing assertion or panic).
        /// This is the same exit code that `panic!()` emits.
        pub fn panic<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 101,
                message: message.into(),
            }
        }

        /// Exit 111 to signify a temporary error (such as resource exhaustion)
        pub fn temporary<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 111,
                message: message.into(),
            }
        }

        /// Exit 126 to signify an environment problem
        /// (the user has set up stuff incorrectly so lorri cannot work)
        pub fn environment_problem<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 126,
                message: message.into(),
            }
        }

        /// Exit 127 to signify a missing executable.
        pub fn missing_executable<T>(message: T) -> ExitError
        where
            T: Into<String>,
        {
            ExitError {
                exitcode: 127,
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

    impl From<std::io::Error> for ExitError {
        fn from(e: std::io::Error) -> ExitError {
            ExitError::temporary(format!("{}", e))
        }
    }
}
