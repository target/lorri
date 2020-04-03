//! Helps instantiate a root slog logger

use crate::cli::Command;
use slog::Drain;

/// Instantiate a root logger appropriate for the subcommand
pub fn root(verbosity: u8, command: &Command) -> slog::Logger {
    let level = match verbosity {
        0 => slog::Level::Info,
        _ => slog::Level::Debug,
    };
    let decorator = match command {
        // direnv swallows stdout, so we must log to stderr
        Command::Direnv(_) => slog_term::TermDecorator::new().stderr().build(),
        _ => slog_term::TermDecorator::new().stdout().build(),
    };
    let drain = slog_term::FullFormat::new(decorator)
        .build()
        .filter_level(level)
        .fuse();
    // This makes all logging go through a mutex. Should logging ever become a bottleneck, consider
    // using slog_async instead.
    let drain = std::sync::Mutex::new(drain).fuse();
    slog::Logger::root(drain, slog::o!())
}
