//! Recursively watch paths for changes, in an extensible and
//! cross-platform way.

use crate::NixFile;
use crossbeam_channel as chan;
use notify::event::ModifyKind;
use notify::{EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use slog_scope::{debug, info};
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use std::time::Duration;

/// A dynamic list of paths to watch for changes, and
/// react to changes when they occur.
pub struct Watch {
    /// Event receiver. Process using `Watch::process`.
    pub rx: chan::Receiver<notify::Result<notify::Event>>,
    notify: RecommendedWatcher,
    watches: HashSet<PathBuf>,
}

/// A debug message string that can only be displayed via `Debug`.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct DebugMessage(String);

impl From<String> for DebugMessage {
    fn from(s: String) -> Self {
        DebugMessage(s)
    }
}

impl From<DebugMessage> for String {
    fn from(d: DebugMessage) -> Self {
        d.0
    }
}

impl From<&DebugMessage> for String {
    fn from(d: &DebugMessage) -> Self {
        d.0.clone()
    }
}

/// Description of the project change that triggered a build.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Reason {
    /// When a project is presented to Lorri to track, it's built for this reason.
    ProjectAdded(NixFile),
    /// When a ping is received.
    PingReceived,
    /// When there is a filesystem change, the first changed file is recorded,
    /// along with a count of other filesystem events.
    FilesChanged(Vec<PathBuf>),
    /// When the underlying notifier reports something strange.
    UnknownEvent(DebugMessage),
}

/// We weren’t able to understand a `notify::Event`.
#[derive(Clone, Debug)]
pub enum EventError {
    /// No message was received from the raw event channel
    RxNoEventReceived,
    /// The changed file event had no file path
    EventHasNoFilePath(notify::Event),
}

impl Watch {
    /// Instantiate a new Watch.
    pub fn try_new() -> Result<Watch, notify::Error> {
        let (tx, rx) = chan::unbounded();

        Ok(Watch {
            notify: Watcher::new(tx, Duration::from_millis(100))?,
            watches: HashSet::new(),
            rx,
        })
    }

    /// Process `notify::Event`s coming in via `Watch::rx`.
    ///
    /// `None` if there were no relevant changes.
    pub fn process(
        &self,
        event: notify::Result<notify::Event>,
    ) -> Option<Result<Reason, EventError>> {
        match event {
            Err(err) => panic!("notify error: {}", err),
            Ok(event) => {
                self.log_event(&event);
                if event.paths.is_empty() {
                    Some(Err(EventError::EventHasNoFilePath(event)))
                } else {
                    let notify::Event { paths, kind, .. } = event;
                    let interesting_paths: Vec<PathBuf> = paths
                        .into_iter()
                        .filter(|p| self.path_is_interesting(p, &kind))
                        .collect();
                    if !interesting_paths.is_empty() {
                        Some(Ok(Reason::FilesChanged(interesting_paths)))
                    } else {
                        None
                    }
                }
            }
        }
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

    fn log_event(&self, event: &notify::Event) {
        debug!("Watch Event: {:#?}", event);
        match &event.kind {
            notify::event::EventKind::Remove(_) if !event.paths.is_empty() => {
                info!("identified removal: {:?}", &event.paths);
            }
            _ => {
                debug!("watch event"; "event" => ?event);
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
        if path.canonicalize()?.starts_with(Path::new("/nix/store")) {
            return Ok(());
        }

        if !self.watches.contains(path) {
            debug!("watching path"; "path" => path.to_str());

            self.notify.watch(path, RecursiveMode::NonRecursive)?;
            self.watches.insert(path.clone());
        }

        if let Some(parent) = path.parent() {
            if !self.watches.contains(parent) {
                debug!("watching parent path"; "parent_path" => parent.to_str());

                self.notify.watch(&parent, RecursiveMode::NonRecursive)?;
            }
        }

        Ok(())
    }

    fn path_is_interesting(&self, path: &PathBuf, kind: &EventKind) -> bool {
        path_match(&self.watches, path)
            && match kind {
                // We ignore metadata modification events for the profiles directory
                // tree as it is a symlink forest that is used to keep track of
                // channels and nix will uconditionally update the metadata of each
                // link in this forest. See https://github.com/NixOS/nix/blob/629b9b0049363e091b76b7f60a8357d9f94733cc/src/libstore/local-store.cc#L74-L80
                // for the unconditional update. These metadata modification events are
                // spurious annd they can easily cause a rebuild-loop when a shell.nix
                // file does not pin its version of nixpkgs or other channels. When
                // a Nix channel is updated we receive many other types of events, so
                // ignoring these metadata modifications will not impact lorri's
                // ability to correctly watch for channel changes.
                EventKind::Modify(ModifyKind::Metadata(_)) => {
                    if path.starts_with(Path::new("/nix/var/nix/profiles/per-user")) {
                        debug!("ignoring spurious metadata change event within the profiles dir"; "path" => path.to_str());
                        false
                    } else {
                        true
                    }
                }
                _ => true,
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

    let matches = |watched: &Path| {
        if event_path == watched {
            debug!(
                "event path directly matches watched path";
                "event_path" => event_path.to_str());

            return true;
        }

        if let Some(parent) = event_parent {
            if parent == watched {
                debug!(
                    "event path parent matches watched path";
                    "event_path" => event_path.to_str(), "parent_path" => parent.to_str());
                return true;
            }
        }

        false
    };

    watched_paths.iter().any(|watched| {
        if matches(watched) {
            return true;
        }

        if let Ok(canonicalized_watch) = watched.canonicalize() {
            if matches(&canonicalized_watch) {
                return true;
            }
        }

        false
    })
}

#[cfg(test)]
mod tests {
    use super::{EventError, Reason, Watch};
    use crate::bash::expect_bash;
    use std::thread::sleep;
    use std::time::Duration;
    use tempfile::tempdir;

    /// upper bound of watcher (if it’s hit, something is broken)
    fn upper_watcher_timeout() -> Duration {
        Duration::from_millis(500)
    }

    /// Collect all notifications
    fn process_all(watch: &Watch) -> Vec<Option<Result<Reason, EventError>>> {
        watch.rx.try_iter().map(|e| watch.process(e)).collect()
    }

    /// Returns true iff the given file has changed
    fn file_changed(watch: &Watch, file_name: &str) -> (bool, Vec<Reason>) {
        let mut reasons = Vec::new();
        let mut changed = false;
        for event in process_all(watch) {
            if let Some(Ok(reason)) = event {
                reasons.push(reason.clone());
                if let Reason::FilesChanged(files) = reason {
                    changed = changed
                        || files
                            .iter()
                            .map(|p| p.file_name())
                            .filter(|f| f.is_some())
                            .map(|f| f.unwrap())
                            .any(|f| f == file_name)
                }
            }
        }
        (changed, reasons)
    }

    fn assert_file_changed(watch: &Watch, file_name: &str) {
        let (file_changed, events) = file_changed(watch, file_name);
        assert!(
            file_changed,
            "no file change notification for '{}'; these events occurred instead: {:?}",
            file_name, events
        );
    }

    /// Returns true iff there were no changes
    fn no_changes(watch: &Watch) -> bool {
        process_all(watch).iter().filter(|e| e.is_some()).count() == 0
    }

    #[cfg(target_os = "macos")]
    fn macos_eat_late_notifications(watcher: &mut Watch) {
        // Sometimes a brand new watch will send a CREATE notification
        // for a file which was just created, even if the watch was
        // created after the file was made.
        //
        // Our tests want to be very precise about which events are
        // received when, so expect these initial events and swallow
        // them.
        //
        // Note, this is racey in the kernel. Otherwise I'd assert
        // this is empty.
        sleep(upper_watcher_timeout());
        process_all(watcher).is_empty();
    }

    #[cfg(not(target_os = "macos"))]
    fn macos_eat_late_notifications(watcher: &mut Watch) {
        // If we're supposedly dealing with a late notification on
        // macOS, we'd better not receive any messages on other
        // platforms.
        //
        // If we do receive any notifications, our test is broken.
        sleep(upper_watcher_timeout());
        assert!(process_all(watcher).is_empty());
    }

    #[test]
    fn trivial_watch_whole_directory() {
        let mut watcher = Watch::try_new().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().to_path_buf()]).unwrap();

        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert_file_changed(&watcher, "foo");

        expect_bash(r#"echo 1 > "$1/foo""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert_file_changed(&watcher, "foo");
    }

    #[test]
    fn trivial_watch_specific_file() {
        let mut watcher = Watch::try_new().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().join("foo")]).unwrap();
        macos_eat_late_notifications(&mut watcher);

        expect_bash(r#"echo 1 > "$1/foo""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert_file_changed(&watcher, "foo");
    }

    #[test]
    fn rename_over_vim() {
        // Vim renames files in to place for atomic writes
        let mut watcher = Watch::try_new().expect("failed creating Watch");
        let temp = tempdir().unwrap();

        expect_bash(r#"mkdir -p "$1""#, &[temp.path().as_os_str()]);
        expect_bash(r#"touch "$1/foo""#, &[temp.path().as_os_str()]);
        watcher.extend(&[temp.path().join("foo")]).unwrap();
        macos_eat_late_notifications(&mut watcher);

        // bar is not watched, expect error
        expect_bash(r#"echo 1 > "$1/bar""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert!(no_changes(&watcher));

        // Rename bar to foo, expect a notification
        expect_bash(r#"mv "$1/bar" "$1/foo""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert_file_changed(&watcher, "foo");

        // Do it a second time
        expect_bash(r#"echo 1 > "$1/bar""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert!(no_changes(&watcher));

        // Rename bar to foo, expect a notification
        expect_bash(r#"mv "$1/bar" "$1/foo""#, &[temp.path().as_os_str()]);
        sleep(upper_watcher_timeout());
        assert_file_changed(&watcher, "foo");
    }
}
