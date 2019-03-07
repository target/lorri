//! Recursively watch paths for changes, in an extensible and
//! cross-platform way.

use notify::{RecommendedWatcher, RecursiveMode, Watcher};
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use std::sync::mpsc::{channel, TryRecvError};

/// A dynamic list of paths to watch for changes, and
/// react to changes when they occur.
pub struct Watch {
    notify: RecommendedWatcher,
    rx: std::sync::mpsc::Receiver<notify::RawEvent>,
    watches: HashSet<PathBuf>,
}

impl Watch {
    /// Instantiate a new Watch.
    pub fn init() -> Result<Watch, notify::Error> {
        let (tx, rx) = channel();

        Ok(Watch {
            notify: Watcher::new_raw(tx)?,
            watches: HashSet::new(),
            rx,
        })
    }

    /// Extend the watch list with an additional list of paths.
    /// Note: Watch maintains a list of already watched paths, and
    /// will not add duplicates.
    pub fn extend(&mut self, paths: &[PathBuf]) -> Result<(), notify::Error> {
        for path in paths {
            self.add_path(&path)?;
            if path.is_dir() {
                self.add_path_recursively(&path)?;
            }
        }

        Ok(())
    }

    /// Wait for a batch of changes to arrive, returning when they do.
    pub fn wait_for_change(&mut self) -> Result<(), ()> {
        debug!("pre-read");

        let mut events = 0;

        // Block for the first record
        match self.rx.recv() {
            Ok(event) => self.handle_event(event),
            Err(err) => {
                debug!("Failure in watch recv: {:#?}", err);
                return Err(());
            }
        }

        events += 1;
        loop {
            match self.rx.try_recv() {
                Ok(event) => {
                    self.handle_event(event);
                    events += 1;
                }
                Err(TryRecvError::Disconnected) => return Err(()),
                Err(TryRecvError::Empty) => {
                    info!("Found {} events", events);
                    return Ok(());
                }
            }
        }
    }

    fn handle_event(&mut self, event: notify::RawEvent) {
        debug!("Watch Event: {:#?}", event);
    }

    fn add_path_recursively(&mut self, path: &PathBuf) -> Result<(), notify::Error> {
        if path.canonicalize()?.starts_with(Path::new("/nix/store")) {
            return Ok(());
        }

        for entry in path.read_dir()? {
            let subpath = entry?.path();

            if subpath.is_dir() {
                self.add_path(&subpath)?;
                self.add_path_recursively(&subpath)?;
            }

            // Skip adding files, watching in the dir will handle it.
        }
        Ok(())
    }

    fn add_path(&mut self, path: &PathBuf) -> Result<(), notify::Error> {
        if !self.watches.contains(path) {
            debug!("Watching path {:?}", path);

            self.notify.watch(path, RecursiveMode::NonRecursive)?;
            self.watches.insert(path.clone());
        }

        Ok(())
    }
}
