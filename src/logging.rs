//! Utilities for configuring env_logger based on the number of -v
//! arguments passed at the CLI
//!
//! Note this is only a default, and the environment variable
//! RUST_LOG will override it.

use env_logger;
use std::env;

/// Potentially set the RUST_LOG environment, and configure env_logger
/// based on if RUST_LOG is set already.
///
/// If RUST_LOG is set already, assume the setter is trying to
/// investigate something specific. However, we also want a useful
/// `-v` option as a quick shortcut.
pub fn init_with_default_log_level(verbosity: u8) {
    let requested_level = level_from_verbosity(verbosity);

    if env::var_os("RUST_LOG").is_none() {
        env::set_var("RUST_LOG", requested_level);
        env_logger::init();
        info!("Setting RUST_LOG to {}", requested_level);
    } else {
        warn!("RUST_LOG is already set, ignoring -v options");
        env_logger::init();
    }
}

/// Convert a number of -v flags in to a default RUST_LOG value
fn level_from_verbosity(verbosity: u8) -> &'static str {
    match verbosity {
        0 => "error",
        1 => "warn",
        2 => "info",
        _ => "debug",
    }
}

#[cfg(test)]
mod tests {
    use super::level_from_verbosity;

    #[test]
    fn test_level_from_verbosity() {
        assert_eq!(level_from_verbosity(0), "error");
        assert_eq!(level_from_verbosity(3), "debug");
        assert_eq!(level_from_verbosity(19), "debug");
    }
}
