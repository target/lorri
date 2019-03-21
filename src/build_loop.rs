//! Uses `builder` and filesystem watch code to repeatedly
//! evaluate and build a given Nix file.

use crate::builder;
use crate::notify;
use crate::pathreduction::reduce_paths;
use crate::roots;
use crate::roots::Roots;
use crate::watch::Watch;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::mpsc::{SendError, Sender};

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
    /// See `build::Info.drvs`
    drvs: HashMap<usize, PathBuf>,
    /// See `build::Info.drvs`
    pub named_drvs: HashMap<String, PathBuf>,
}

/// Results of a single, failing build.
#[derive(Debug, Clone)]
pub struct BuildExitFailure {
    /// stderr log output
    pub log_lines: Vec<String>,
}

/// The BuildLoop repeatedly builds the Nix expression in
/// `nix_root_path` each time a source file influencing
/// a previous build changes.
/// Additionally, we create GC roots for the build results.
pub struct BuildLoop {
    /// A nix source file which can be built
    nix_root_path: PathBuf,
    roots: Roots,
    /// A channel that build results are sent back over
    tx: Sender<Event>,
    /// Watches all input files for changes.
    /// As new input files are discovered, they are added to the watchlist.
    watch: Watch,
}

impl BuildLoop {
    /// Instatiate a new BuildLoop. Uses an internal filesystem
    /// watching implementation.
    pub fn new(nix_root_path: PathBuf, roots: Roots, tx: Sender<Event>) -> BuildLoop {
        BuildLoop {
            nix_root_path,
            roots,
            tx,
            watch: Watch::init().expect("Failed to initialize watch"),
        }
    }

    /// Loop forever, watching the filesystem for changes. Blocks.
    /// Sends `Event`s over `Self.tx` once they happen.
    /// When new filesystem changes are detected while a build is
    /// still running, it is finished first before starting a new build.
    pub fn forever(&mut self) {
        loop {
            let mut go = || -> Result<(), SingleBuildError> {
                let event = self.once()?;
                self.tx.send(event)?;
                self.watch.wait_for_change().expect("Waiter exited");
                Ok(())
            };
            match go() {
                Err(err) => panic!("{}: {:?}", "Builder failed", err),
                Ok(()) => {}
            }
        }
    }

    fn once(&mut self) -> Result<Event, SingleBuildError> {
        self.tx.send(Event::Started)?;
        let build = builder::run(&self.nix_root_path)?;

        let paths = build.paths;
        debug!("original paths: {:?}", paths.len());

        let paths = reduce_paths(&paths);
        debug!("  -> reduced to: {:?}", paths.len());

        debug!("named drvs: {:#?}", build.named_drvs);

        let mut event = BuildResults {
            drvs: HashMap::new(),
            named_drvs: HashMap::new(),
        };
        for (name, drv) in build.named_drvs.iter() {
            event.named_drvs.insert(
                name.clone(),
                self.roots.add(&format!("attr-{}", name), &drv)?,
            );
        }

        for (i, drv) in build.drvs.iter().enumerate() {
            event
                .drvs
                .insert(i, self.roots.add(&format!("build-{}", i), &drv)?);
        }

        // add all new (reduced) nix sources to the input source watchlist
        self.watch.extend(&paths.into_iter().collect::<Vec<_>>())?;

        Ok(if build.exec_result.success() {
            Event::Completed(event)
        } else {
            Event::Failure(BuildExitFailure {
                log_lines: build.log_lines,
            })
        })
    }
}

#[derive(Debug)]
enum SingleBuildError {
    Build(builder::Error),
    AddRoot(roots::AddRootError),
    Notify(notify::Error),
    ChannelSend(SendError<Event>),
}
impl From<builder::Error> for SingleBuildError {
    fn from(e: builder::Error) -> SingleBuildError {
        SingleBuildError::Build(e)
    }
}
impl From<roots::AddRootError> for SingleBuildError {
    fn from(e: roots::AddRootError) -> SingleBuildError {
        SingleBuildError::AddRoot(e)
    }
}
impl From<notify::Error> for SingleBuildError {
    fn from(e: notify::Error) -> SingleBuildError {
        SingleBuildError::Notify(e)
    }
}
impl From<SendError<Event>> for SingleBuildError {
    fn from(e: SendError<Event>) -> SingleBuildError {
        SingleBuildError::ChannelSend(e)
    }
}
