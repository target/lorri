//! Execute arbitrary Nix builds

use std::path::PathBuf;
use std::process::{Command, Output, Stdio};
use std::str;

/// Describme what exactly we should nix-build
pub enum BuildInstruction<'a> {
    /// nix-build a literal Nix expression
    Expression(&'a str),
}

/// The public API for the eager builder.
pub struct NixBuild {}

impl NixBuild {
    /// Arbitrary Nix build
    pub fn build(instruction: &BuildInstruction) -> Result<Vec<PathBuf>, BuildError> {
        let args = match instruction {
            BuildInstruction::Expression(expr) => ["--expr", expr, "--no-out-link"],
        };

        let child = Command::new("nix-build")
            .args(&args)
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::inherit())
            .output()?;

        if child.status.success() {
            Ok(str::from_utf8(&child.stdout)?
                .lines()
                .map(PathBuf::from)
                .collect())
        } else {
            Err(BuildError::Failed(child))
        }
    }
}

/// Possible errors from an individual build
#[derive(Debug)]
pub enum BuildError {
    /// IO error executing nix-instantiate
    Io(std::io::Error),

    /// nix-build failed to execute, providing the entire Output
    /// object for examination
    Failed(Output),

    /// nix-build executed successfully, but the output was not
    /// parseable. This should not happen, because stdout should
    /// be only ascii -- indicating a serious problem with the
    /// execution.
    Decode(str::Utf8Error),
}
impl From<std::io::Error> for BuildError {
    fn from(e: std::io::Error) -> Self {
        BuildError::Io(e)
    }
}
impl From<str::Utf8Error> for BuildError {
    fn from(e: str::Utf8Error) -> Self {
        BuildError::Decode(e)
    }
}
