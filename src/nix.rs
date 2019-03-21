//! Execute Nix commands using a builder-pattern abstraction.
//! ```rust
//! extern crate lorri;
//! use lorri::nix;
//!
//! #[macro_use] extern crate serde_derive;
//! #[derive(Debug, Deserialize, PartialEq, Eq)]
//! struct Author {
//!     name: String,
//!     contributions: usize
//! }
//!
//! fn main() {
//!     let output: Result<Vec<Author>, _> = nix::CallOpts::expression(r#"
//!       { name }:
//!       {
//!         contributors = [
//!           { inherit name; contributions = 99; }
//!         ];
//!       }
//!     "#)
//!         .argstr("name", "Jill")
//!         .attribute("contributors")
//!         .value();
//!
//!     assert_eq!(
//!         output.unwrap(),
//!         vec![
//!             Author { name: "Jill".to_string(), contributions: 99 },
//!         ]
//!     );
//! }
//! ```

use serde_json;
use std::collections::HashMap;
use std::ffi::OsStr;
use std::io::BufRead;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use vec1::Vec1;

/// Execute Nix commands using a builder-pattern abstraction.
#[derive(Default, Clone)]
pub struct CallOpts {
    expression: String,
    attribute: Option<String>,
    argstrs: HashMap<String, String>,
}

impl CallOpts {
    /// Create a CallOpts with the Nix expression `expr`.
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// let output: Result<u8, _> = nix::CallOpts::expression("let x = 5; in x")
    ///     .value();
    /// assert_eq!(
    ///   output.unwrap(), 5
    /// );
    /// ```
    pub fn expression(expr: &str) -> CallOpts {
        CallOpts {
            expression: expr.to_string(),
            ..Default::default()
        }
    }

    /// Evaluate a sub attribute of the expression. Only supports one:
    /// calling attribute() multiple times is supported, but overwrites
    /// the previous attribute.
    ///
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// let output: Result<u8, _> = nix::CallOpts::expression("let x = 5; in { a = x; }")
    ///     .attribute("a")
    ///     .value();
    /// assert_eq!(
    ///   output.unwrap(), 5
    /// );
    /// ```
    ///
    ///
    /// This is due to the following difficult to handle edge case of
    ///
    /// nix-instantiate --eval --strict --json -E '{ a = 1; b = 2; }' -A a -A b
    ///
    /// producing "12".
    pub fn attribute(&mut self, attr: &str) -> &mut Self {
        self.attribute = Some(attr.to_string());
        self
    }

    /// Specify an argument to the expression, where the argument's value
    /// is to be interpreted as a string.
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// let output: Result<String, _> = nix::CallOpts::expression(r#"{ name }: "Hello, ${name}!""#)
    ///     .argstr("name", "Jill")
    ///     .value();
    /// assert_eq!(
    ///   output.unwrap(), "Hello, Jill!"
    /// );
    /// ```
    pub fn argstr(&mut self, name: &str, value: &str) -> &mut Self {
        self.argstrs.insert(name.to_string(), value.to_string());
        self
    }

    /// Evaluate the expression and parameters, and interpret as type T:
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    ///
    /// #[macro_use] extern crate serde_derive;
    /// #[derive(Debug, Deserialize, PartialEq, Eq)]
    /// struct Author {
    ///     name: String,
    ///     contributions: usize
    /// }
    ///
    /// fn main() {
    ///     let output: Result<Vec<Author>, _> = nix::CallOpts::expression(r#"
    ///       { name }:
    ///       {
    ///         contributors = [
    ///           { inherit name; contributions = 99; }
    ///         ];
    ///       }
    ///     "#)
    ///         .argstr("name", "Jill")
    ///         .attribute("contributors")
    ///         .value();
    ///
    ///     assert_eq!(
    ///         output.unwrap(),
    ///         vec![
    ///             Author { name: "Jill".to_string(), contributions: 99 },
    ///         ]
    ///     );
    /// }
    /// ```
    pub fn value<T>(&self) -> Result<T, EvaluationError>
    where
        T: serde::de::DeserializeOwned,
    {
        let mut cmd = Command::new("nix-instantiate");
        cmd.args(&["--eval", "--json", "--strict"]);

        cmd.args(self.command_arguments());

        let output = cmd.output()?;

        if output.status.success() {
            Ok(serde_json::from_slice(&output.stdout.clone())?)
        } else {
            Err(output.into())
        }
    }

    /// Build the expression and return a path to the build result:
    ///
    /// ```rust
    /// extern crate lorri;
    /// extern crate tempfile;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    ///
    /// let tempdir = tempfile::tempdir().unwrap();
    /// let location = nix::CallOpts::expression(r#"
    ///             import <nixpkgs> {}
    /// "#)
    ///         .attribute("hello")
    ///         .path(&tempdir.path())
    ///         .unwrap()
    ///         .into_os_string()
    ///         .into_string().unwrap()
    ///         ;
    ///
    /// println!("{:?}", location);
    /// assert!(location.contains("/nix/store"));
    /// assert!(location.contains("hello-"));
    /// ```
    ///
    /// Note, path() return an error if there are multiple paths
    /// returned by Nix:
    ///
    /// ```rust
    /// extern crate lorri;
    /// extern crate tempfile;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    ///
    /// let tempdir = tempfile::tempdir().unwrap();
    /// let paths = nix::CallOpts::expression(r#"
    ///             { inherit (import <nixpkgs> {}) hello git; }
    /// "#)
    ///         .path(&tempdir.path());
    ///
    /// match paths {
    ///    Err(nix::OnePathError::TooManyResults) => {},
    ///    otherwise => panic!(otherwise)
    /// }
    /// ```
    pub fn path(&self, gc_root_dir: &Path) -> Result<PathBuf, OnePathError> {
        let mut paths = self.paths(gc_root_dir)?.into_vec();

        match (paths.pop(), paths.pop()) {
            // Exactly zero
            (None, _) => Err(BuildError::NoResult.into()),

            // Exactly one
            (Some(path), None) => Ok(path),

            // More than one
            (Some(_), Some(_)) => Err(OnePathError::TooManyResults),
        }
    }

    /// Build the expression and return a list of paths to the build results:
    ///
    /// ```rust
    /// extern crate lorri;
    /// extern crate tempfile;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    ///
    /// let tempdir = tempfile::tempdir().unwrap();
    /// let mut paths = nix::CallOpts::expression(r#"
    ///             { inherit (import <nixpkgs> {}) hello git; }
    /// "#)
    ///         .paths(&tempdir.path())
    ///         .unwrap()
    ///         .into_iter()
    ///         .map(|path| { println!("{:?}", path); format!("{:?}", path) });
    /// assert!(paths.next().unwrap().contains("git-"));
    /// assert!(paths.next().unwrap().contains("hello-"));
    /// ```
    pub fn paths(&self, gc_root_dir: &Path) -> Result<Vec1<PathBuf>, BuildError> {
        if !gc_root_dir.exists() || !gc_root_dir.is_dir() {
            return Err(BuildError::GcRootNotADirectory);
        }

        let mut cmd = Command::new("nix-build");
        cmd.args(&[
            OsStr::new("--out-link"),
            gc_root_dir.join(Path::new("result")).as_os_str(),
        ]);

        cmd.args(self.command_arguments());

        cmd.stderr(Stdio::inherit());
        let output = cmd.output()?;

        if output.status.success() {
            let lines: Result<Vec<String>, _> = output.stdout.lines().collect();

            let paths: Vec<PathBuf> = lines?.iter().map(PathBuf::from).collect();

            if let Ok(vec1) = Vec1::from_vec(paths) {
                Ok(vec1)
            } else {
                Err(BuildError::NoResult)
            }
        } else {
            Err(output.into())
        }
    }

    /// Fetch common arguments passed to Nix's CLI, specifically
    /// the --expr expression, -A attribute, and --argstr values.
    fn command_arguments(&self) -> Vec<&OsStr> {
        let mut ret: Vec<&str> = vec![];

        ret.push("--expr");
        ret.push(&self.expression);

        if let Some(ref attr) = self.attribute {
            ret.push("-A");
            ret.push(attr);
        }

        for (name, value) in self.argstrs.iter() {
            ret.push("--argstr");
            ret.push(name);
            ret.push(value);
        }

        ret.into_iter().map(OsStr::new).collect()
    }
}

/// Possible error conditions encountered when executing Nix evaluation commands.
#[derive(Debug)]
pub enum EvaluationError {
    /// A system-level IO error occured while executing Nix.
    Io(std::io::Error),

    /// Nix execution failed.
    ExecutionFailed(std::process::Output),

    /// The data returned from nix-instantiate did not match the
    /// data time you expect.
    Decoding(serde_json::Error),
}

impl From<std::io::Error> for EvaluationError {
    fn from(e: std::io::Error) -> EvaluationError {
        EvaluationError::Io(e)
    }
}

impl From<serde_json::Error> for EvaluationError {
    fn from(e: serde_json::Error) -> EvaluationError {
        EvaluationError::Decoding(e)
    }
}

impl From<std::process::Output> for EvaluationError {
    fn from(output: std::process::Output) -> EvaluationError {
        if output.status.success() {
            panic!(
                "Output is successful, but we're in error handling: {:#?}",
                output
            );
        }

        EvaluationError::ExecutionFailed(output)
    }
}

/// Possible error conditions encountered when executing Nix build commands.
#[derive(Debug)]
pub enum BuildError {
    /// A system-level IO error occured while executing Nix.
    Io(std::io::Error),

    /// Nix execution failed.
    ExecutionFailed(std::process::Output),

    /// Build produced no paths
    NoResult,

    /// The directory passed for the GC root either does not exist or
    /// is not a directory.
    GcRootNotADirectory,
}

impl From<std::io::Error> for BuildError {
    fn from(e: std::io::Error) -> BuildError {
        BuildError::Io(e)
    }
}

impl From<std::process::Output> for BuildError {
    fn from(output: std::process::Output) -> BuildError {
        if output.status.success() {
            panic!(
                "Output is successful, but we're in error handling: {:#?}",
                output
            );
        }

        BuildError::ExecutionFailed(output)
    }
}

/// Possible error conditions encountered when executing a Nix build
/// and expecting a single result
#[derive(Debug)]
pub enum OnePathError {
    /// Too many paths were returned
    TooManyResults,

    /// Standard Build Error results
    Build(BuildError),
}

impl From<BuildError> for OnePathError {
    fn from(e: BuildError) -> OnePathError {
        OnePathError::Build(e)
    }
}

#[cfg(test)]
mod tests {
    use super::CallOpts;
    use std::ffi::OsStr;

    #[test]
    fn cmd_arguments() {
        let mut nix = CallOpts::expression("my-cool-expression");
        nix.attribute("hello");
        nix.argstr("foo", "bar");

        let exp: Vec<&OsStr> = [
            "--expr",
            "my-cool-expression",
            "-A",
            "hello",
            "--argstr",
            "foo",
            "bar",
        ]
        .into_iter()
        .map(OsStr::new)
        .collect();
        assert_eq!(exp, nix.command_arguments());
    }
}
