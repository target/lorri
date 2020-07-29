//! Common errors.

use std::ffi::OsString;
use std::fmt;
use std::io::Error as IoError;
use std::os::unix::ffi::OsStrExt;
use std::process::{Command, ExitStatus};

/// An error that can occur during a build.
#[derive(Clone, Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum BuildError {
    /// A system-level IO error occurred during the build.
    Io {
        /// Error message of the underlying error. Stored as a string because we need `BuildError`
        /// to implement `Copy`, but `io::Error` does not implement `Copy`.
        msg: String,
    },

    /// An error occurred while spawning a Nix process.
    ///
    /// Usually this means that the relevant Nix executable was not on the $PATH.
    Spawn {
        /// The command that failed. Stored as a string because we need `BuildError` to implement
        /// `Copy`, but `Command` does not implement `Copy`.
        cmd: String,

        /// Error message of the underlying error. Stored as a string because we need `BuildError`
        /// to implement `Copy`, but `io::Error` does not implement `Copy`.
        msg: String,
    },

    /// The Nix process returned with a non-zero exit code.
    Exit {
        /// The command that failed. Stored as a string because we need `BuildError` to implement
        /// `Copy`, but `Command` does not implement `Copy`.
        cmd: String,

        /// The `ExitStatus` of the command. The smart constructor `BuildError::exit` asserts that
        /// it is non-successful.
        status: Option<i32>,

        /// Error logs of the failed process.
        logs: Vec<LogLine>,
    },

    /// There was something wrong with the output of the Nix command.
    ///
    /// This error may for example indicate that the wrong number of outputs was produced.
    Output {
        /// Error message explaining the nature of the output error.
        msg: String,
    },
}

use serde::{Serialize, Serializer};

/// A line from stderr log output.
#[derive(Debug, Clone)]
pub struct LogLine(pub OsString);

/// Implement Serialize in a way that prints file names as strings.
/// TODO: this won’t return the actual filenames if they are not valid utf8.
/// so scripts won’t be able to read them. Maybe print a warning in that case?
impl Serialize for LogLine {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let LogLine(oss) = self;
        serializer.serialize_str(&*oss.to_string_lossy())
    }
}

impl From<OsString> for LogLine {
    fn from(oss: OsString) -> Self {
        LogLine(oss)
    }
}

impl From<String> for LogLine {
    fn from(s: String) -> Self {
        LogLine(OsString::from(s))
    }
}

struct LogLinesDisplay<'a>(&'a [LogLine]);

impl<'a> fmt::Display for LogLinesDisplay<'a> {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        for l in self.0 {
            let mut s = String::from_utf8_lossy(l.0.as_bytes()).into_owned();
            s.push('\n');
            formatter.write_str(&s)?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json;

    fn build_exit() -> BuildError {
        BuildError::Exit {
            cmd: "ebs".to_string(),
            status: Some(1),
            logs: vec![
                OsString::from("this is a test of the emergency broadcast system").into(),
                OsString::from("you will hear a tone").into(),
                OsString::from("remember, this is only a test").into(),
            ],
        }
    }

    #[test]
    fn logline_json_readable() -> Result<(), serde_json::Error> {
        assert!(serde_json::to_string(&build_exit())?.contains("emergency"));
        Ok(())
    }

    #[test]
    fn logline_json_roundtrip() -> Result<(), serde_json::Error> {
        serde_json::from_str::<serde_json::Value>(&serde_json::to_string(&build_exit())?)
            .map(|_| ())
    }
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
            BuildError::Io { msg } => write!(f, "I/O error: {}", msg),
            BuildError::Spawn { cmd, msg } => write!(
                f,
                "failed to spawn Nix process. Is Nix installed and on the $PATH?\n\
                 $ {}\n\
                 {}",
                cmd, msg,
            ),
            BuildError::Exit { cmd, status, logs } => write!(
                f,
                "Nix process returned exit code {}.\n\
                 $ {}\n\
                 {}",
                status.map_or("<unknown>".to_string(), |c| i32::to_string(&c)),
                cmd,
                LogLinesDisplay(logs)
            ),
            BuildError::Output { msg } => write!(f, "{}", msg),
        }
    }
}

impl BuildError {
    /// Smart constructor for `BuildError::Io`
    pub fn io<D>(e: D) -> BuildError
    where
        D: fmt::Debug,
    {
        BuildError::Io {
            msg: format!("{:?}", e),
        }
    }

    /// Smart constructor for `BuildError::Spawn`
    pub fn spawn<D>(cmd: &Command, e: D) -> BuildError
    where
        D: fmt::Display,
    {
        BuildError::Spawn {
            cmd: format!("{:?}", cmd),
            msg: format!("{}", e),
        }
    }

    /// Smart constructor for `BuildError::Exit`
    pub fn exit(cmd: &Command, status: ExitStatus, logs: Vec<OsString>) -> BuildError {
        assert!(
            !status.success(),
            "cannot create an exit error from a successful status code"
        );
        BuildError::Exit {
            cmd: format!("{:?}", cmd),
            status: status.code(),
            logs: logs.iter().map(|l| LogLine::from(l.clone())).collect(),
        }
    }

    /// Smart constructor for `BuildError::Output`
    pub fn output(msg: String) -> BuildError {
        BuildError::Output { msg }
    }

    /// Is there something the user can do about this error?
    pub fn is_actionable(&self) -> bool {
        match self {
            BuildError::Io { .. } => false,
            BuildError::Spawn { .. } => true, // install Nix or fix $PATH
            BuildError::Exit { .. } => true,  // fix Nix expression
            BuildError::Output { .. } => true, // fix Nix expression
        }
    }
}
