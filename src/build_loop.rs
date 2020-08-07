//! Uses `builder` and filesystem watch code to repeatedly
//! evaluate and build a given Nix file.

use crate::builder;
use crate::daemon::LoopHandlerEvent;
use crate::error::BuildError;
use crate::nix::options::NixOptions;
use crate::pathreduction::reduce_paths;
use crate::project::roots;
use crate::project::roots::Roots;
use crate::project::Project;
use crate::watch::{DebugMessage, EventError, Reason, Watch};
use crate::NixFile;
use crossbeam_channel as chan;
use slog_scope::{debug, warn};
use std::path::PathBuf;
use std::time::Duration;

/// Builder events sent back over `BuildLoop.tx`.
#[derive(Clone, Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum Event {
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
        failure: BuildError,
    },
}

/// Denotes a build to be started and its reason
#[derive(Clone, Debug, Serialize)]
struct StartTrigger {
    /// The shell.nix file to be built
    nix_file: NixFile,
    /// The reason the build was triggered
    reason: Reason,
}

/// Results of a single, successful build.
#[derive(Clone, Debug, Serialize)]
pub struct BuildResults {
    /// See `build::Info.outputPaths
    pub output_paths: builder::OutputPaths<roots::RootPath>,
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
    /// Extra options to pass to each nix invocation
    extra_nix_options: NixOptions,
}

impl From<StartTrigger> for Event {
    fn from(StartTrigger { nix_file, reason }: StartTrigger) -> Self {
        Event::Started { nix_file, reason }
    }
}

impl<'a> BuildLoop<'a> {
    /// Instatiate a new BuildLoop. Uses an internal filesystem
    /// watching implementation.
    pub fn new(project: &'a Project, extra_nix_options: NixOptions) -> BuildLoop<'a> {
        BuildLoop {
            project,
            watch: Watch::try_new().expect("Failed to initialize watch"),
            extra_nix_options,
        }
    }

    /// Loop forever, watching the filesystem for changes. Blocks.
    /// Sends `Event`s over `Self.tx` once they happen.
    /// When new filesystem changes are detected while a build is
    /// still running, it is finished first before starting a new build.
    #[allow(clippy::drop_copy, clippy::zero_ptr)] // triggered by `select!`
    pub fn forever(&mut self, tx: chan::Sender<LoopHandlerEvent>, rx_ping: chan::Receiver<()>) {
        let translate_reason = |rsn| match rsn {
            Ok(rsn) => rsn,
            // we should continue and just cite an unknown reason
            Err(EventError::EventHasNoFilePath(msg)) => {
                warn!(
                    "event has no file path; possible issue with the watcher?";
                    "message" => ?msg
                );
                // can’t Clone `Event`s, so we return the Debug output here
                Reason::UnknownEvent(DebugMessage(format!("{:#?}", msg)))
            }
            Err(EventError::RxNoEventReceived) => {
                panic!("The file watcher died!");
            }
        };

        // The project has just been added, so run the builder in the first iteration
        let mut output_paths = self.once_with_send(
            &tx,
            Event::Started {
                nix_file: self.project.nix_file.clone(),
                reason: Reason::ProjectAdded(self.project.nix_file.clone()),
            },
        );

        // Drain pings initially: we're going to trigger a first build anyway
        rx_ping.try_iter().for_each(drop);

        let rx_notify = self.watch.rx.clone();

        let maybe_get_one_reason_to_build = |self_: &Self,
                                             output_paths: &Option<builder::OutputPaths<_>>,
                                             timeout: Option<Duration>|
         -> Option<StartTrigger> {
            let timeout_chan = timeout.map(chan::after).unwrap_or_else(chan::never);
            chan::select! {
                recv(rx_notify) -> msg => match msg {
                    Ok(msg) => {
                        match self_.watch.process(msg) {
                            Some(rsn) => {
                                Some(StartTrigger{
                                    nix_file: self_.project.nix_file.clone(),
                                    reason: translate_reason(rsn)
                                })
                            },
                            None => {
                                // No relevant file events
                                None
                            }
                        }
                    }
                    // TODO: can we just ignore Err?
                    Err(_) => None
                },
                recv(rx_ping) -> msg => match (msg, output_paths) {
                    (Ok(()), Some(output_paths)) => {
                        // TODO: why is this check done here?
                        if !output_paths.shell_gc_root_is_dir() {
                            Some(StartTrigger{
                                nix_file: self_.project.nix_file.clone(),
                                reason: Reason::PingReceived
                            })
                        }
                        else { None }
                    },
                    // TODO: can we just ignore these two cases?
                    (Ok(()), None) => None,
                    (Err(_), _) => None
                },
                recv(timeout_chan) -> _  => None
            }
        };

        let mut to_start = None;

        loop {
            if to_start.is_none() {
                to_start =
                    maybe_get_one_reason_to_build(self, &output_paths, None /* blocking */);
            }

            // If there is some reason to build, run the build!
            if to_start.is_some() {
                // there are possibly other notifications which would trigger the same build: drain
                // them
                let first_trigger = to_start.take().unwrap();
                loop {
                    to_start = maybe_get_one_reason_to_build(
                        self,
                        &output_paths,
                        Some(Duration::from_millis(150)),
                    );
                    match &to_start {
                        Some(StartTrigger { nix_file, .. })
                            if nix_file == &first_trigger.nix_file =>
                        {
                            debug!("skipping building a project twice"; "trigger"=>?to_start);
                        }
                        // build also a new project
                        _ => break,
                    }
                }

                output_paths = self.once_with_send(&tx, first_trigger.into())
            }
        }
    }

    fn once_with_send(
        &mut self,
        tx: &chan::Sender<LoopHandlerEvent>,
        reason: Event,
    ) -> Option<builder::OutputPaths<roots::RootPath>> {
        let send = |msg| {
            tx.send(LoopHandlerEvent::from(msg))
                .expect("Failed to send an event")
        };
        send(reason);
        match self.once() {
            Ok(result) => {
                send(Event::Completed {
                    nix_file: self.project.nix_file.clone(),
                    result: result.clone(),
                });
                Some(result.output_paths)
            }
            Err(e) => {
                if e.is_actionable() {
                    send(Event::Failure {
                        nix_file: self.project.nix_file.clone(),
                        failure: e,
                    })
                } else {
                    panic!("Unrecoverable error:\n{:#?}", e);
                }
                None
            }
        }
    }

    /// Execute a single build of the environment.
    ///
    /// This will create GC roots and expand the file watch list for
    /// the evaluation.
    pub fn once(&mut self) -> Result<BuildResults, BuildError> {
        let run_result = builder::run(
            &self.project.nix_file,
            &self.project.cas,
            &self.extra_nix_options,
        )?;
        self.register_paths(&run_result.referenced_paths)?;
        self.root_result(run_result.result)
    }

    fn register_paths(&mut self, paths: &[PathBuf]) -> Result<(), notify::Error> {
        let original_paths_len = paths.len();
        let paths = reduce_paths(&paths);
        debug!("paths reduced"; "from" => original_paths_len, "to" => paths.len());

        // add all new (reduced) nix sources to the input source watchlist
        self.watch.extend(paths.into_iter().collect::<Vec<_>>())?;

        Ok(())
    }

    fn root_result(&mut self, build: builder::RootedPath) -> Result<BuildResults, BuildError> {
        let roots = Roots::from_project(&self.project);

        Ok(BuildResults {
            output_paths: roots.create_roots(build).map_err(BuildError::io)?,
        })
    }
}
