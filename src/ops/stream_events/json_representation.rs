use std::convert::{TryFrom, TryInto};

use crate::rpc;

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub(super) enum Event {
    SectionEnd,
    /// A build has started
    BuildStarted {
        /// The shell.nix file for the building project
        shell_file: String,
        /// The reason the build started
        reason: Reason,
    },
    /// A build completed successfully
    BuildCompleted {
        /// The shell.nix file for the building project
        shell_file: String,
        /// The result of the build
        result: Vec<String>,
    },
    /// A build command returned a failing exit status
    BuildFailure {
        /// The shell.nix file for the building project
        shell_file: String,
        /// The error that exited the build
        failure: BuildError,
    },
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Reason {
    /// When a project is presented to Lorri to track, it's built for this reason.
    ProjectAdded,
    /// When a ping is received.
    PingReceived,
    /// When there is a filesystem change, the first changed file is recorded,
    /// along with a count of other filesystem events.
    FilesChanged(Vec<String>),
    /// When the underlying notifier reports something strange.
    UnknownEvent(String),
}

#[derive(Clone, Debug, Serialize, Deserialize)]
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
        logs: Vec<String>,
    },

    /// There was something wrong with the output of the Nix command.
    ///
    /// This error may for example indicate that the wrong number of outputs was produced.
    Output {
        /// Error message explaining the nature of the output error.
        msg: String,
    },
}

impl TryFrom<rpc::Monitor_Reply> for Event {
    type Error = String;

    fn try_from(mr: rpc::Monitor_Reply) -> Result<Self, Self::Error> {
        Event::try_from(mr.event)
    }
}

impl TryFrom<rpc::Event> for Event {
    type Error = String;

    fn try_from(re: rpc::Event) -> Result<Self, Self::Error> {
        use rpc::Event_kind::*;

        Ok(match re.kind {
            section_end => Event::SectionEnd,
            started => Event::BuildStarted {
                shell_file: re.nix_file.ok_or("missing nix file!")?.path,
                reason: re.reason.ok_or("missing reason!")?.try_into()?,
            },
            completed => Event::BuildCompleted {
                shell_file: re.nix_file.ok_or("missing nix file!")?.path,
                result: re.result.ok_or("missing result!")?.into(),
            },
            failure => Event::BuildFailure {
                shell_file: re.nix_file.ok_or("missing nix file!")?.path,
                failure: re.failure.ok_or("missing failure log")?.try_into()?,
            },
        })
    }
}

impl TryFrom<rpc::Reason> for Reason {
    type Error = String;

    fn try_from(rr: rpc::Reason) -> Result<Self, Self::Error> {
        use rpc::Reason_kind::*;

        Ok(match rr.kind {
            ping_received => Reason::PingReceived,
            project_added => Reason::ProjectAdded,
            files_changed => Reason::FilesChanged(rr.files.ok_or("missing files!")?),
            unknown => Reason::UnknownEvent(rr.debug.ok_or("missing debug string!")?),
        })
    }
}

impl TryFrom<rpc::Failure> for BuildError {
    type Error = &'static str;

    fn try_from(rf: rpc::Failure) -> Result<Self, Self::Error> {
        use rpc::Failure_kind::*;

        Ok(match rf.kind {
            io => BuildError::Io {
                msg: rf.msg.ok_or("io failure without msg!")?,
            },
            spawn => BuildError::Spawn {
                cmd: rf.cmd.ok_or("spawn error missing cmd!")?,
                msg: rf.msg.ok_or("spawn failure without msg!")?,
            },
            exit => BuildError::Exit {
                cmd: rf.cmd.ok_or("exit error missing cmd!")?,
                logs: rf.logs.ok_or("exit error missing logs!")?,
                status: rf.status.map(|c| c as i32),
            },
            output => BuildError::Output {
                msg: rf.msg.ok_or("output failure without msg!")?,
            },
        })
    }
}

impl From<rpc::Outcome> for Vec<String> {
    fn from(ro: rpc::Outcome) -> Self {
        vec![ro.project_root]
    }
}
