//! Uses `builder` and filesystem watch code to repeatedly
//! evaluate and build a given Nix file.

use crate::builder;
use crate::builder::RunStatus;
use crate::notify;
use crate::pathreduction::reduce_paths;
use crate::project::roots;
use crate::project::roots::Roots;
use crate::project::Project;
use crate::watch::{DebugMessage, RawEventError, Reason, Watch};
use crate::NixFile;
use serde::{
    de::{self, Visitor},
    Deserialize, Deserializer, Serialize, Serializer,
};
use std::path::PathBuf;
use std::sync::mpsc::{channel, Sender};

/// Builder events sent back over `BuildLoop.tx`.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Event {
    /// A heartbeat to send over sockets to keep them alive
    Heartbeat,
    /// Demarks a stream of events from recent history becoming live
    SectionEnd,
    /// A build has started
    Started {
        /// The shell.nix file for the building project
        nix_file: NixFile,
        /// The reason the build started
        reason: Reason,
    },
    /// A build completed successfully
    Completed {
        /// The shell.nix file for the building project
        nix_file: NixFile,
        /// The result of the build
        result: BuildResults,
    },
    /// A build command returned a failing exit status
    Failure {
        /// The shell.nix file for the building project
        nix_file: NixFile,
        /// The error that exited the build
        failure: BuildExitFailure,
    },
}

/// Results of a single, successful build.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct BuildResults {
    /// See `build::Info.outputPaths
    pub output_paths: builder::OutputPaths<roots::RootPath>,
}

/// Results of a single, failing build.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BuildExitFailure {
    /// stderr log output
    pub log_lines: Vec<LogLine>,
}

/// A line from stderr log output
#[derive(Debug, Clone)]
pub struct LogLine(std::ffi::OsString);

impl Serialize for LogLine {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let LogLine(oss) = self;
        serializer.serialize_str(&*oss.to_string_lossy())
    }
}

impl<'de> Deserialize<'de> for LogLine {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        use std::fmt;

        struct LLVisitor;

        impl<'de> Visitor<'de> for LLVisitor {
            type Value = LogLine;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("a string")
            }

            fn visit_str<E>(self, value: &str) -> Result<LogLine, E>
            where
                E: de::Error,
            {
                Ok(LogLine(std::ffi::OsString::from(value)))
            }
        }

        deserializer.deserialize_str(LLVisitor)
    }
}

impl From<std::ffi::OsString> for LogLine {
    fn from(oss: std::ffi::OsString) -> Self {
        LogLine(oss)
    }
}

#[cfg(test)]
mod tests {
    use super::{BuildExitFailure, Event, LogLine};
    use crate::NixFile;
    use serde_json;

    fn build_failure() -> Event {
        Event::Failure {
            nix_file: NixFile(std::path::PathBuf::from("/somewhere/shell.nix")),
            failure: BuildExitFailure {
                log_lines: vec![
                    LogLine::from(std::ffi::OsString::from(
                        "this is a test of the emergency broadcast system",
                    )),
                    LogLine::from(std::ffi::OsString::from("you will hear a tone")),
                    LogLine::from(std::ffi::OsString::from("remember, this is only a test")),
                ],
            },
        }
    }

    #[test]
    fn logline_json_readable() -> Result<(), serde_json::Error> {
        // just don't explode, you know?
        assert!(serde_json::to_string(&build_failure())?.contains("emergency"));
        Ok(())
    }

    #[test]
    fn logline_json_roundtrip() -> Result<(), serde_json::Error> {
        // just don't explode, you know?
        serde_json::from_str::<serde_json::Value>(&serde_json::to_string(&build_failure())?)
            .map(|_| ())
    }

    #[test]
    fn logline_bincode_roundtrip() -> Result<(), bincode::Error> {
        // just don't explode, you know?
        //let serzd = bincode::serialize(&build_failure()).unwrap();
        //panic!(format!("serialized as: {:?} {:?}", String::from_utf8(serzd.clone()).unwrap(), serzd));

        match bincode::deserialize(&bincode::serialize(&build_failure())?)? {
            Event::Failure { failure: f, .. } => {
                let LogLine(ret) = f.log_lines.get(0).unwrap().clone();
                assert!(ret.into_string().unwrap().contains("emergency"));
            }
            otherwise => panic!(otherwise),
        }
        Ok(())
    }
}

/// The BuildLoop repeatedly builds the Nix expression in
/// `project` each time a source file influencing
/// a previous build changes.
/// Additionally, we create GC roots for the build results.
pub struct BuildLoop<'a> {
    /// Project to be built.
    project: &'a Project,
    /// Watches all input files for changes.
    /// As new input files are discovered, they are added to the watchlist.
    watch: Watch,
}

impl<'a> BuildLoop<'a> {
    /// Instatiate a new BuildLoop. Uses an internal filesystem
    /// watching implementation.
    pub fn new(project: &'a Project) -> BuildLoop<'a> {
        BuildLoop {
            project,
            watch: Watch::init().expect("Failed to initialize watch"),
        }
    }

    /// Loop forever, watching the filesystem for changes. Blocks.
    /// Sends `Event`s over `Self.tx` once they happen.
    /// When new filesystem changes are detected while a build is
    /// still running, it is finished first before starting a new build.
    pub fn forever<T: From<Event>>(&mut self, tx: Sender<T>) {
        let send = |msg| tx.send(T::from(msg)).expect("Failed to send an event");

        send(Event::Started{
            nix_file: self.project.nix_file.clone(),
            reason: Reason::ProjectAdded(
            self.project.nix_file.clone(),
            )});

        loop {
            match self.once() {
                Ok(result) => send(Event::Completed{
                    nix_file: self.project.nix_file.clone(),
                    result
                }),
                Err(BuildError::Recoverable(failure)) => send(Event::Failure{
                    nix_file: self.project.nix_file.clone(),
                    failure
                }),
                Err(BuildError::Unrecoverable(err)) => {
                    panic!("Unrecoverable error:\n{:#?}", err);
                }
            }

            let reason = match self.watch.wait_for_change() {
                Ok(r) => r,
                // we should continue and just cite an unknown reason
                Err(RawEventError::EventHasNoFilePath(msg)) => {
                    warn!(
                        "Event has no file path; possible issue with the watcher?: {:#?}",
                        msg
                    );
                    // can’t Clone RawEvents, so we return the Debug output here
                    Reason::UnknownEvent(DebugMessage::from(format!("{:#?}", msg)))
                }
                Err(RawEventError::RxNoEventReceived) => {
                    panic!("The file watcher died!");
                }
            };

            // TODO: Make err use Display instead of Debug.
            // Otherwise user errors (especially for IO errors)
            // are pretty hard to debug. Might need to review
            // whether we can handle some errors earlier than here.
            send(Event::Started{
                nix_file: self.project.nix_file.clone(),
                reason
            });
        }
    }

    /// Execute a single build of the environment.
    ///
    /// This will create GC roots and expand the file watch list for
    /// the evaluation.
    pub fn once(&mut self) -> Result<BuildResults, BuildError> {
        let (tx, rx) = channel();
        let run_result = builder::run(tx, &self.project.nix_file, &self.project.cas)?;

        self.register_paths(&run_result.referenced_paths)?;

        let lines = rx.iter().map(LogLine::from).collect();

        match run_result.status {
            RunStatus::FailedAtInstantiation => Err(BuildError::Recoverable(BuildExitFailure {
                log_lines: lines,
            })),
            RunStatus::FailedAtRealize => Err(BuildError::Recoverable(BuildExitFailure {
                log_lines: lines,
            })),
            RunStatus::Complete(path) => self.root_result(path),
        }
    }

    fn register_paths(&mut self, paths: &[PathBuf]) -> Result<(), notify::Error> {
        debug!("original paths: {:?}", paths.len());

        let paths = reduce_paths(&paths);
        debug!("  -> reduced to: {:?}", paths.len());

        // add all new (reduced) nix sources to the input source watchlist
        self.watch.extend(&paths.into_iter().collect::<Vec<_>>())?;

        Ok(())
    }

    fn root_result(&mut self, build: builder::RootedPath) -> Result<BuildResults, BuildError> {
        let roots = Roots::from_project(&self.project);

        Ok(BuildResults {
            output_paths: roots.create_roots(build)?,
        })
    }
}

/// Error classes returnable from a build.
///
/// Callers should probably exit on Unrecoverable errors, but retry
/// with Recoverable errors.
#[derive(Debug)]
pub enum BuildError {
    /// Recoverable errors are caused by failures to evaluate or build
    /// the Nix expression itself.
    Recoverable(BuildExitFailure),

    /// Unrecoverable errors are anything else: a broken Nix,
    /// permission problems, etc.
    Unrecoverable(UnrecoverableErrors),
}

/// Unrecoverable errors due to internal failures of the plumbing.
/// For example `exec` failing, permissions problems, kernel faults,
/// etc.
///
/// See the corresponding Error struct documentation for further
/// information.
#[derive(Debug)]
#[allow(missing_docs)]
pub enum UnrecoverableErrors {
    Build(builder::Error),
    AddRoot(roots::AddRootError),
    Notify(notify::Error),
}
impl From<builder::Error> for BuildError {
    fn from(e: builder::Error) -> BuildError {
        BuildError::Unrecoverable(UnrecoverableErrors::Build(e))
    }
}
impl From<roots::AddRootError> for BuildError {
    fn from(e: roots::AddRootError) -> BuildError {
        BuildError::Unrecoverable(UnrecoverableErrors::AddRoot(e))
    }
}
impl From<notify::Error> for BuildError {
    fn from(e: notify::Error) -> BuildError {
        BuildError::Unrecoverable(UnrecoverableErrors::Notify(e))
    }
}
