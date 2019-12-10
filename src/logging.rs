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
    let drain = slog_async::Async::new(drain)
        .overflow_strategy(slog_async::OverflowStrategy::Block)
        .build()
        .fuse();
    slog::Logger::root(drain, slog::o!("lorri_version" => crate::VERSION_BUILD_REV))
}
