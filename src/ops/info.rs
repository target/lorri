//! The info callable is for printing

use crate::ops::error::{ok, OpResult};
use slog_scope::info;

/// See the documentation for lorri::cli::Command::Info for more
/// details.
pub fn main() -> OpResult {
    // lorri version and root shell.nix file are attached to the logger as key-value pairs, so they
    // are part of every log line.
    info!("Hello Nix!");
    ok()
}
