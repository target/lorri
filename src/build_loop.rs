//! Uses `builder` and filesystem watch code to repeatedly
//! evaluate and build a given Nix file.

use crate::builder;
use crate::nix::{GcRootTempDir, StorePath};
use crate::notify;
use crate::pathreduction::reduce_paths;
use crate::project::roots;
use crate::project::roots::Roots;
use crate::project::Project;
use crate::watch::Watch;
use std::sync::mpsc::Sender;

/// Builder events sent back over `BuildLoop.tx`.
#[derive(Clone, Debug)]
pub enum Event {
    /// The build has started
    Started,
    /// The build completed successfully
    Completed(BuildResults),
    /// The build command returned a failing exit status
    Failure(BuildExitFailure),
}

/// Results of a single, successful build.
#[derive(Clone, Debug)]
pub struct BuildResults {
    /// See `build::Info.outputPaths
    pub output_paths: builder::OutputPaths<roots::RootPath>,
}

/// Results of a single, failing build.
#[derive(Debug, Clone)]
pub struct BuildExitFailure {
    /// stderr log output
    pub log_lines: Vec<std::ffi::OsString>,
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
    pub fn forever(&mut self, tx: Sender<Event>) {
        loop {
            // TODO: Make err use Display instead of Debug.
            // Otherwise user errors (especially for IO errors)
            // are pretty hard to debug. Might need to review
            // whether we can handle some errors earlier than here.
            tx.send(Event::Started)
                .expect("Failed to notify a started evaluation");

            match self.once() {
                Ok(result) => {
                    tx.send(Event::Completed(result))
                        .expect("Failed to notify the results of a completed evaluation");
                }
                Err(BuildError::Recoverable(failure)) => {
                    tx.send(Event::Failure(failure))
                        .expect("Failed to notify the results of a failed evaluation");
                }
                Err(BuildError::Unrecoverable(err)) => panic!("Unrecoverable error!\n{:#?}", err),
            }

            self.watch.wait_for_change().expect("Waiter exited");
        }
    }

    /// Execute a single build of the environment.
    ///
    /// This will create GC roots and expand the file watch list for
    /// the evaluation.
    pub fn once(&mut self) -> Result<BuildResults, BuildError> {
        let build = builder::run(&self.project.nix_file, &self.project.cas)?;

        match build {
            builder::Info::Failure(f) => Err(BuildError::Recoverable(BuildExitFailure {
                log_lines: f.log_lines,
            })),
            builder::Info::Success(s) => self.once_(s),
        }
    }

    fn once_(
        &mut self,
        build: builder::Success<StorePath, GcRootTempDir>,
    ) -> Result<BuildResults, BuildError> {
        let roots = Roots::from_project(&self.project);

        let paths = build.paths;
        debug!("original paths: {:?}", paths.len());

        let paths = reduce_paths(&paths);
        debug!("  -> reduced to: {:?}", paths.len());

        debug!("named drvs: {:#?}", build.output_paths);

        let event = BuildResults {
            output_paths: roots.create_roots(build.output_paths)?,
        };
        // now we can drop the temporary gc_root in build because we added static roots
        drop(build.gc_root_temp_dir);

        // add all new (reduced) nix sources to the input source watchlist
        self.watch.extend(&paths.into_iter().collect::<Vec<_>>())?;

        Ok(event)
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
