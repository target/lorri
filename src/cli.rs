//! Defines the CLI interface using structopt.

use std::path::PathBuf;

#[derive(StructOpt, Debug)]
#[structopt(name = "lorri")]
/// Global arguments which set global program state. Most
/// arguments will be to sub-commands.
pub struct Arguments {
    /// Activate debug logging. Multiple occurrences are accepted for backwards compatibility, but
    /// have no effect.
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
    Direnv(DirenvOptions),

    /// Show information about the current Lorri project
    #[structopt(name = "info", alias = "information")]
    Info(InfoOptions),

    /// Build `shell.nix` whenever an input file changes
    #[structopt(name = "watch")]
    Watch(WatchOptions),

    /// Run services
    #[structopt(name = "services")]
    Services(ServicesOptions),

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

/// Options for `watch` subcommand.
#[derive(StructOpt, Debug)]
pub struct DirenvOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
}

/// Options for `watch` subcommand.
#[derive(StructOpt, Debug)]
pub struct InfoOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
}

/// Options for `watch` subcommand.
#[derive(StructOpt, Debug)]
pub struct WatchOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
    /// Exit after a the first build
    #[structopt(long = "once")]
    pub once: bool,
}

/// Options for `services` subcommand.
#[derive(StructOpt, Debug)]
pub struct ServicesOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "services", parse(from_os_str), default_value = "services.nix")]
    pub config_file: PathBuf,
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
    pub nix_file: PathBuf,
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
