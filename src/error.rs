//! Common errors.

use std::ffi::OsString;
use std::fmt;
use std::io::Error as IoError;
use std::process::ExitStatus;

/// An error that can occur during a build.
#[derive(Clone, Debug)]
pub enum BuildError {
    /// A system-level IO error occurred during the build.
    // The underlying error is stored as a string because we need `BuildError` to implement `Copy`,
    // but `io::Error` does not implement `Copy`.
    Io(String),

    /// An error occurred while spawning a Nix process.
    ///
    /// Usually this means that the relevant Nix executable was not on the $PATH.
    // The underlying error is stored as a string because we need `BuildError` to implement `Copy`,
    // but `io::Error` does not implement `Copy`.
    Spawn(String),

    /// The Nix process returned with a non-zero exit code.
    ///
    /// The `ExitStatus` is guaranteed to be not successful.
    Exit(ExitStatus, Vec<OsString>),

    /// There was something wrong with the output of the Nix command.
    ///
    /// This error may for example indicate that the wrong number of outputs was produced.
    Output(String),
}

impl From<IoError> for BuildError {
    fn from(e: IoError) -> BuildError {
        BuildError::io(e)
    }
}

impl From<notify::Error> for BuildError {
    fn from(e: notify::Error) -> BuildError {
        BuildError::io(e)
    }
}

impl From<serde_json::Error> for BuildError {
    fn from(e: serde_json::Error) -> BuildError {
        BuildError::io(e)
    }
}

impl fmt::Display for BuildError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BuildError::Io(e) => write!(f, "I/O error: {}", e),
            BuildError::Spawn(e) => write!(
                f,
                "failed to spawn Nix process: {}. Is Nix installed and on the $PATH?",
                e
            ),
            BuildError::Exit(status, logs) => write!(
                f,
                "Nix process returned with exit code {}. Error logs:\n{}",
                status
                    .code()
                    .map_or("<unknown>".to_string(), |c| i32::to_string(&c)),
                logs.iter()
                    .map(|l| l.to_string_lossy())
                    .collect::<Vec<_>>()
                    .join("\n")
            ),
            BuildError::Output(msg) => write!(f, "{}", msg),
        }
    }
}

impl BuildError {
    /// Smart constructor for `BuildError::Io`
    pub fn io<D>(e: D) -> BuildError
    where
        D: fmt::Display,
    {
        BuildError::Io(format!("{}", e))
    }

    /// Smart constructor for `BuildError::Spawn`
    pub fn spawn<D>(e: D) -> BuildError
    where
        D: fmt::Display,
    {
        BuildError::Spawn(format!("{}", e))
    }

    /// Smart constructor for `BuildError::Exit`
    pub fn exit(status: ExitStatus, logs: Vec<OsString>) -> BuildError {
        assert!(
            !status.success(),
            "cannot create an exit error from a successful status code"
        );
        BuildError::Exit(status, logs)
    }

    /// Smart constructor for `BuildError::Output`
    pub fn output(msg: String) -> BuildError {
        BuildError::Output(msg)
    }

    /// Is there something the user can do about this error?
    pub fn is_actionable(&self) -> bool {
        match self {
            BuildError::Io(_) => false,
            BuildError::Spawn(_) => true,   // install Nix or fix $PATH
            BuildError::Exit(_, _) => true, // fix Nix expression
            BuildError::Output(_) => true,  // fix Nix expression
        }
    }
}
