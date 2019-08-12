//! Defines the CLI interface using structopt.

use std::path::PathBuf;
use NixFile;

#[derive(StructOpt, Debug)]
#[structopt(name = "lorri")]
/// Global arguments which set global program state. Most
/// arguments will be to sub-commands.
pub struct Arguments {
    /// Increase debug logging, can be passed multiple times.
    /// Supports up to -vvvv, and this setting is ignored if RUST_LOG
    /// is set.
    #[structopt(short = "v", long = "verbose", parse(from_occurrences))]
    pub verbosity: u8,

    /// Sub-command to execute
    #[structopt(subcommand)]
    pub command: Command,
}

#[derive(StructOpt, Debug)]
/// Sub-commands which Lorri can execute
pub enum Command {
    /// Emit shell script intended to be evaluated as part of
    /// direnv's .envrc, via: `eval "$(lorri direnv)"`
    #[structopt(name = "direnv")]
    Direnv,

    /// Show information about the current Lorri project
    #[structopt(name = "info", alias = "information")]
    Info,

    /// Build `shell.nix` whenever an input file changes
    #[structopt(name = "watch")]
    Watch,

    /// Start the multi-project daemon. Replaces `lorri watch`
    #[structopt(name = "daemon")]
    Daemon,

    /// (plumbing) Tell the lorri daemon to care about the current directory's project
    #[structopt(name = "ping_")]
    Ping_(Ping_),

    /// Upgrade Lorri
    #[structopt(name = "self-upgrade", alias = "self-update")]
    Upgrade(UpgradeTo),

    /// Bootstrap files for a new setup
    #[structopt(name = "init")]
    Init,
}

/// Send a message with a lorri project.
///
/// Pinging with a project tells the daemon that the project was recently interacted with.
/// If the daemon has not been pinged for a project, it begins listening. If it does not
/// get pinged for a long time, it may stop watching the project for changes.
#[derive(StructOpt, Debug)]
pub struct Ping_ {
    /// The .nix file to watch and build on changes.
    #[structopt(parse(from_os_str))]
    pub nix_file: NixFile,
}

/// A stub struct to represent how what we want to upgrade to.
#[derive(StructOpt, Debug)]
#[structopt(name = "basic")]
pub struct UpgradeTo {
    /// the path to a local check out of Lorri.
    #[structopt(subcommand)]
    pub source: Option<UpgradeSource>,
}

/// Version-specifiers of different upgrade targets.
#[derive(StructOpt, Debug)]
pub enum UpgradeSource {
    /// Upgrade to the current rolling-release version, will be
    /// fetched from git and built locally. rolling-release is
    /// expected to be more stable than master. (default)
    #[structopt(name = "rolling-release")]
    RollingRelease,

    /// Upgrade to the current version from the master branch, which
    /// will be fetched from git and built locally.
    #[structopt(name = "master")]
    Master,

    /// Upgrade to a version in an arbitrary local directory.
    #[structopt(name = "local")]
    Local(LocalDest),
}

/// Install an arbitrary version of Lorri from a local directory.
#[derive(StructOpt, Debug)]
pub struct LocalDest {
    /// the path to a local check out of Lorri.
    #[structopt(parse(from_os_str))]
    pub path: PathBuf,
}
