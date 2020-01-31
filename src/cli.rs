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
/// Sub-commands which lorri can execute
pub enum Command {
    /// Emit shell script intended to be evaluated as part of direnv's .envrc, via: `eval "$(lorri
    /// direnv)"`
    #[structopt(name = "direnv")]
    Direnv(DirenvOptions),

    /// Show information about a lorri project
    #[structopt(name = "info")]
    Info(InfoOptions),

    /// Open a new project shell
    #[structopt(name = "shell")]
    Shell(ShellOptions),

    /// (internal) Used internally by `lorri shell`
    #[structopt(
        name = "internal__start_user_shell",
        raw(setting = "structopt::clap::AppSettings::Hidden")
    )]
    StartUserShell_(StartUserShellOptions_),

    /// Build project whenever an input file changes
    #[structopt(name = "watch")]
    Watch(WatchOptions),

    /// Start the multi-project daemon. Replaces `lorri watch`
    #[structopt(name = "daemon")]
    Daemon,

    /// (internal) Tell the lorri daemon to care about the current directory's project
    #[structopt(
        name = "internal__ping",
        raw(setting = "structopt::clap::AppSettings::Hidden")
    )]
    Ping_(Ping_),

    /// (plumbing) Ask the lorri daemon to report build events as they occur
    #[structopt(name = "stream_events_")]
    StreamEvents_(StreamEvents_),

    /// Upgrade Lorri
    #[structopt(name = "self-upgrade", alias = "self-update")]
    Upgrade(UpgradeTo),

    /// Write bootstrap files to current directory to create a new lorri project
    #[structopt(name = "init")]
    Init,
}

/// Options for the `direnv` subcommand.
#[derive(StructOpt, Debug)]
pub struct DirenvOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
}

/// Options for the `info` subcommand.
#[derive(StructOpt, Debug)]
pub struct InfoOptions {
    /// The .nix file in the current directory to use
    // The "shell-file" argument has no default value. That's on purpose: sometimes users have
    // projects with multiple shell files. This way, they are forced to think about which shell
    // file was causing problems when they submit a bug report.
    #[structopt(long = "shell-file", parse(from_os_str))]
    pub nix_file: PathBuf,
}

/// Options for the `shell` subcommand.
#[derive(StructOpt, Debug)]
pub struct ShellOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
    /// If true, load environment from cache
    #[structopt(long = "cached")]
    pub cached: bool,
}

/// Options for the `internal__start_user_shell` subcommand.
#[derive(StructOpt, Debug)]
pub struct StartUserShellOptions_ {
    /// The path of the parent shell's binary
    #[structopt(long = "shell-path", parse(from_os_str))]
    pub shell_path: PathBuf,
    /// The .nix file in the current directory to use to instantiate the project
    #[structopt(long = "shell-file", parse(from_os_str))]
    pub nix_file: PathBuf,
}

/// Options for the `watch` subcommand.
#[derive(StructOpt, Debug)]
pub struct WatchOptions {
    /// The .nix file in the current directory to use
    #[structopt(long = "shell-file", parse(from_os_str), default_value = "shell.nix")]
    pub nix_file: PathBuf,
    /// Exit after a the first build
    #[structopt(long = "once")]
    pub once: bool,
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

/// Stream events from the daemon.
#[derive(StructOpt, Debug)]
pub struct StreamEvents_ {
    #[structopt(long, default_value = "all")]
    /// The kind of events to report
    pub kind: EventKind,
}

/// A stub struct to represent how what we want to upgrade to.
#[derive(StructOpt, Debug)]
#[structopt(name = "basic")]
pub struct UpgradeTo {
    /// the path to a local check out of lorri.
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

/// Install an arbitrary version of lorri from a local directory.
#[derive(StructOpt, Debug)]
pub struct LocalDest {
    /// the path to a local check out of lorri.
    #[structopt(parse(from_os_str))]
    pub path: PathBuf,
}
