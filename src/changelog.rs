//! Data structures to interpret the lorri change log.

/// A representation of the release.nix change log format.
#[derive(Deserialize, Debug)]
pub struct Log {
    /// a list of ordered change log entries, newest first.
    pub entries: Vec<Entry>,
}

/// A specific changelog entry
#[derive(Deserialize, Debug)]
pub struct Entry {
    /// The version number (note: increasing number, not x.y.z)
    pub version: usize,

    /// A plain-text blob of change log text.
    pub changes: String,
}
