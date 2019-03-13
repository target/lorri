//! Recursively watch paths for changes, in an extensible and
//! cross-platform way.

use crate::mpsc::FilterTimeoutIterator;
use notify::{RecommendedWatcher, RecursiveMode, Watcher};
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use std::sync::mpsc::{channel, RecvError};
use std::time::Duration;

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
    pub fn wait_for_change(&mut self) -> Result<usize, ()> {
        self.block()
    }

    /// Block until we have at least one event
    pub fn block(&mut self) -> Result<usize, ()> {
        if self.blocking_iter().next().is_none() {
            debug!("No event received!");
            return Err(());
        }

        Ok(1 + self.process_ready()?)
    }

    /// Block until we have at least one event
    pub fn block_timeout(&self, timeout: Duration) -> Result<usize, ()> {
        if let Some(Ok(_)) = self.timeout_iter(timeout).next() {
            Ok(1 + self.process_ready()?)
        } else {
            Err(())
        }
    }

    fn blocking_iter<'a>(&'a self) -> impl 'a + Iterator<Item = notify::RawEvent> {
        self.rx
            .iter()
            .filter(move |event| self.event_is_interesting(event))
            .inspect(move |event| self.handle_event(event))
    }

    fn timeout_iter<'a>(
        &'a self,
        timeout: Duration,
    ) -> impl 'a + Iterator<Item = Result<notify::RawEvent, RecvError>> {
        FilterTimeoutIterator::new(&self.rx, timeout, move |event| {
            self.event_is_interesting(event)
        })
        .inspect(move |event| {
            if let Ok(event) = event {
                self.handle_event(event)
            }
        })
    }

    /// Non-blocking, read all the events already received -- draining
    /// the event queue.
    fn process_ready(&self) -> Result<usize, ()> {
        let mut events = 0;
        let mut iter = self.timeout_iter(Duration::from_millis(100));
        loop {
            match iter.next() {
                Some(Ok(event)) => {
                    debug!("Received event: {:#?}", event);
                    events += 1;
                }
                Some(Err(RecvError)) => return Err(()),
                None => {
                    info!("Found {} events", events);
                    return Ok(events);
                }
            }
        }
    }

    fn handle_event(&self, event: &notify::RawEvent) {
        debug!("Watch Event: {:#?}", event);
        match (&event.op, &event.path) {
            (Ok(notify::op::REMOVE), Some(path)) => {
                info!("identified file removal: {:?}", path);
            }
            otherwise => {
                debug!("watch event: {:#?}", otherwise);
            }
        }
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

        if let Some(parent) = path.parent() {
            if !self.watches.contains(parent) {
                debug!("Watching parent path {:?}", parent);

                self.notify.watch(&parent, RecursiveMode::NonRecursive)?;
            }
        }

        Ok(())
    }

    fn event_is_interesting(&self, event: &notify::RawEvent) -> bool {
        match event.path {
            Some(ref path) => path_match(&self.watches, path),
            None => false,
        }
    }
}

/// Determine if the event path is covered by our list of watched
/// paths.
///
/// Returns true if:
///   - the event's path directly names a path in our
///     watch list
///   - the event's path names a canonicalized path in our watch list
///   - the event's path's parent directly names a path in our watch
///     list
///   - the event's path's parent names a canonicalized path in our
///     watch list
fn path_match(watched_paths: &HashSet<PathBuf>, event_path: &Path) -> bool {
    let event_parent = event_path.parent();

    watched_paths.iter().any(|watched| {
        if watched == event_path {
            debug!(
                "Event path ({:?}) directly matches watched path",
                event_path
            );
            return true;
        }

        if let Some(parent) = event_parent {
            if watched == parent {
                debug!(
                    "Event path ({:?}) parent ({:?}) matches watched path",
                    event_path, parent
                );
                return true;
            }
        }

        if let Ok(canonicalized_watch) = watched.canonicalize() {
            if canonicalized_watch == event_path {
                debug!(
                    "Event path ({:?}) matches canonicalized watch path ({:?}) ",
                    event_path, canonicalized_watch
                );
                return true;
            }

            if let Some(parent) = event_parent {
                if canonicalized_watch == parent {
                    debug!(
                        "Event path ({:?}) parent ({:?}) matches canonicalized watch path ({:?}) ",
                        event_path, parent, canonicalized_watch
                    );
                    return true;
                }
            }
        }

        false
    })
}

#[cfg(test)]
mod tests {
    use super::Watch;
    use crate::bash::expect_bash;
    use std::time::Duration;
    use tempfile::tempdir;

    #[test]
    fn trivial_watch_whole_directory() {
        let mut watcher = Watch::init().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().to_path_buf()]).unwrap();
        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_ok());

        expect_bash(r#"echo 1 > "$1/foo""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_ok());
    }

    #[test]
    fn trivial_watch_specific_file() {
        let mut watcher = Watch::init().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().join("foo")]).unwrap();
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_err());

        expect_bash(r#"echo 1 > "$1/foo""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_ok());
    }

    #[test]
    fn rename_over_vim() {
        // Vim renames files in to place for atomic writes
        let mut watcher = Watch::init().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().join("foo")]).unwrap();

        // bar is not watched, expect error
        expect_bash(r#"echo 1 > "$1/bar""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_err());

        // Rename bar to foo, expect a notification
        expect_bash(r#"mv "$1/bar" "$1/foo""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_ok());

        // Do it a second time
        expect_bash(r#"echo 1 > "$1/bar""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_err());

        // Rename bar to foo, expect a notification
        expect_bash(r#"mv "$1/bar" "$1/foo""#, &[temp.path().as_os_str()]);
        assert!(watcher.block_timeout(Duration::from_secs(1)).is_ok());
    }
}
