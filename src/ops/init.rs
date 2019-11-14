//! Bootstrap a new lorri project

use crate::ops::error::{ok_msg, ExitError, OpResult};
use std::fs::File;
use std::io;
use std::io::Write;
use std::path::Path;

fn create_if_missing(path: &Path, contents: &str, msg: &str) -> Result<(), io::Error> {
    if path.exists() {
        println!("- {} {}", msg, path.display());
        Ok(())
    } else {
        let mut f = File::create(path)?;
        f.write_all(contents.as_bytes())?;
        println!("- Writing {}", path.display());
        Ok(())
    }
}

/// See the documentation for lorri::cli::Command::Init for
/// more details
pub fn main(default_shell: &str, default_envrc: &str) -> OpResult {
    create_if_missing(
        Path::new("./shell.nix"),
        default_shell,
        "shell.nix exists, skipping. Make sure it is of a form that works with nix-shell.",
    )
    .map_err(|e| ExitError::user_error(format!("{}", e)))?;

    create_if_missing(
        Path::new("./.envrc"),
        default_envrc,
        ".envrc exists, skipping. Please add 'eval \"$(lorri direnv)\" to it to set up lorri support."
    ).map_err(|e| ExitError::user_error(format!("{}", e)))?;

    ok_msg(String::from("\nSetup done."))
}
