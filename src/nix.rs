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

use osstrlines;
use serde_json;
use std::collections::HashMap;
use std::ffi::OsStr;
use std::path::{Path, PathBuf};
use std::process::{ChildStderr, ChildStdout, Command, ExitStatus, Stdio};
use std::thread::{spawn, JoinHandle};
use vec1::Vec1;

/// Execute Nix commands using a builder-pattern abstraction.
#[derive(Clone)]
pub struct CallOpts {
    input: Input,
    attribute: Option<String>,
    argstrs: HashMap<String, String>,
    log_level: LogLevel,
    stderr_inspector: Option<()>,
}

/// Which input to give nix.
#[derive(Clone)]
enum Input {
    /// A nix expression string.
    Expression(String),
    /// A nix file.
    File(PathBuf),
}

/// Nix's log levels
#[derive(Clone)]
pub enum LogLevel {
    /// Only capture messages explaining why the Nix invocation failed.
    ErrorsOnly,
    /// Capture useful messages about what Nix is doing. This is the default.
    Informational,
    /// Capture more informational messages.
    Talkative,
    /// Capture even more informational messages.
    Chatty,
    /// Capture debug information.
    Debug,
    /// Capture vast amounts of debug information.
    Vomit,
}
impl LogLevel {
    fn to_argument(&self) -> Option<&'static OsStr> {
        match self {
            LogLevel::ErrorsOnly => Some(OsStr::new("-q")),
            LogLevel::Informational => None,
            LogLevel::Talkative => Some(OsStr::new("-v")),
            LogLevel::Chatty => Some(OsStr::new("-vv")),
            LogLevel::Debug => Some(OsStr::new("-vvv")),
            LogLevel::Vomit => Some(OsStr::new("-vvvv")),
        }
    }
}

/// Opaque type to keep a temporary GC root directory alive.
/// Once it is dropped, the GC root is removed.
pub struct GcRootTempDir(tempfile::TempDir);

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
            input: Input::Expression(expr.to_string()),
            attribute: None,
            argstrs: HashMap::new(),
            log_level: LogLevel::Informational,
            stderr_inspector: None,
        }
    }

    /// Create a CallOpts with the Nix file `nix_file`.
    pub fn file(nix_file: PathBuf) -> CallOpts {
        CallOpts {
            input: Input::File(nix_file),
            attribute: None,
            argstrs: HashMap::new(),
            log_level: LogLevel::Informational,
            stderr_inspector: None,
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

    /// Specify the log level for the Nix instantiation
    pub fn log_level(&mut self, log_level: LogLevel) -> &mut Self {
        self.log_level = log_level;
        self
    }

    pub fn inspect_stderr(&mut self, f: ()) -> &mut Self {
        self.stderr_inspector = Some(f);
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
        T: serde::de::DeserializeOwned + Send,
    {
        let mut cmd = Command::new("nix-instantiate");
        cmd.args(&["--eval", "--json", "--strict"]);

        cmd.args(self.command_arguments());

        let ret = self.execute(cmd, serde_json::from_reader, (|_| ()))?;

        if ret.0.success() {
            Ok(ret.1?)
        } else {
            Err(ret.into())
        }
    }

    /// Build the expression and return a path to the build result:
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    /// # use std::env;
    /// # env::set_var("NIX_PATH", "nixpkgs=./nix/bogus-nixpkgs/");
    ///
    /// let (location, gc_root) = nix::CallOpts::expression(r#"
    ///             import <nixpkgs> {}
    /// "#)
    ///         .attribute("hello")
    ///         .build_path()
    ///         .unwrap()
    ///         ;
    ///
    /// let location = location.into_os_string().into_string().unwrap();
    /// println!("{:?}", location);
    /// assert!(location.contains("/nix/store"));
    /// assert!(location.contains("hello-"));
    /// drop(gc_root);
    /// ```
    ///
    /// `path` returns a lock to the GC roots created by the Nix call
    /// (`gc_root` in the example above). Until that is dropped,
    /// a Nix garbage collect will not remove the store paths created
    /// by `build_path()`.
    ///
    /// Note, `build_path()` returns an error if there are multiple store
    /// paths returned by Nix:
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    /// # use std::env;
    /// # env::set_var("NIX_PATH", "nixpkgs=./nix/bogus-nixpkgs/");
    ///
    /// let paths = nix::CallOpts::expression(r#"
    ///             { inherit (import <nixpkgs> {}) hello git; }
    /// "#)
    ///         .build_path();
    ///
    /// match paths {
    ///    Err(nix::OnePathError::TooManyResults) => {},
    ///    otherwise => panic!(otherwise)
    /// }
    /// ```
    pub fn build_path(&self) -> Result<(PathBuf, GcRootTempDir), OnePathError> {
        let (pathsv1, gc_root) = self.build_paths()?;
        let mut paths = pathsv1.into_vec();

        match (paths.pop(), paths.pop()) {
            // Exactly zero
            (None, _) => Err(BuildError::NoResult.into()),

            // Exactly one
            (Some(path), None) => Ok((path, gc_root)),

            // More than one
            (Some(_), Some(_)) => Err(OnePathError::TooManyResults),
        }
    }

    /// Build the expression and return a list of paths to the build results.
    /// Like `.build_path()`, except it returns all store paths.
    ///
    /// ```rust
    /// extern crate lorri;
    /// use lorri::nix;
    /// use std::path::{Path, PathBuf};
    /// # use std::env;
    /// # env::set_var("NIX_PATH", "nixpkgs=./nix/bogus-nixpkgs/");
    ///
    /// let (paths, gc_root) = nix::CallOpts::expression(r#"
    ///             { inherit (import <nixpkgs> {}) hello git; }
    /// "#)
    ///         .build_paths()
    ///         .unwrap();
    /// let mut paths = paths
    ///         .into_iter()
    ///         .map(|path| { println!("{:?}", path); format!("{:?}", path) });
    /// assert!(paths.next().unwrap().contains("git-"));
    /// assert!(paths.next().unwrap().contains("hello-"));
    /// drop(gc_root);
    /// ```
    pub fn build_paths(&self) -> Result<(Vec1<PathBuf>, GcRootTempDir), BuildError> {
        // TODO: temp_dir writes to /tmp by default, we should
        // create a wrapper using XDG_RUNTIME_DIR instead,
        // which is per-user and (on systemd systems) a tmpfs.
        let gc_root_dir = tempfile::TempDir::new()?;

        let mut cmd = Command::new("nix-build");

        // Create a gc root to the build output
        cmd.args(&[
            OsStr::new("--out-link"),
            gc_root_dir.path().join(Path::new("result")).as_os_str(),
        ]);

        cmd.args(self.command_arguments());

        cmd.stderr(Stdio::inherit());
        let output = cmd.output()?;

        if output.status.success() {
            let stdout: &[u8] = &output.stdout;
            let paths: Vec<PathBuf> = osstrlines::Lines::from(stdout)
                .map(|line| line.map(PathBuf::from))
                .collect::<Result<Vec<PathBuf>, _>>()?;

            if let Ok(vec1) = Vec1::from_vec(paths) {
                Ok((vec1, GcRootTempDir(gc_root_dir)))
            } else {
                Err(BuildError::NoResult)
            }
        } else {
            Err(output.into())
        }
    }

    /// Execute the interior Nix command, passing in stdout and stderr
    /// handlers.
    ///
    /// `stdout_f` and `stderr_f` are run in separate threads, and
    /// care should be taken that they don't block. Neither may panic.
    ///
    /// This command returns Ok as long as the Nix command was started
    /// successfully. In other words, an Ok does NOT imply the command
    /// was _successful_.
    fn execute<SOF, SOR, SEF, SER, E>(
        &self,
        mut cmd: Command,
        stdout_f: SOF,
        stderr_f: SEF,
    ) -> std::io::Result<(ExitStatus, SOR, SER)>
    where
        SOF: (Fn(ChildStdout) -> SOR) + Send + 'static,
        SOR: Send + 'static,
        SEF: (Fn(ChildStderr) -> SER) + Send + 'static,
        SER: Send + 'static,
        E: std::convert::From<std::io::Error>,
    {
        cmd.stdin(Stdio::null());
        cmd.stdout(Stdio::piped());
        cmd.stderr(Stdio::piped());

        let mut child = cmd.spawn()?;

        // Process stdout and stderr with the user-defined functions
        let stdout = child.stdout.take().expect("stdout must be piped()");
        let stderr = child.stderr.take().expect("stderr must be piped()");

        let stdout_thread: JoinHandle<SOR> = spawn(move || stdout_f(stdout));
        let stderr_thread: JoinHandle<SER> = spawn(move || stderr_f(stderr));

        // Collect the results and return
        Ok((
            child.wait()?,
            stdout_thread
                .join()
                .expect("must not panic when processing stdout"),
            stderr_thread
                .join()
                .expect("must not panic when processing stderr"),
        ))
    }

    /// Fetch common arguments passed to Nix's CLI, specifically
    /// the --expr expression, -A attribute, and --argstr values.
    fn command_arguments(&self) -> Vec<&OsStr> {
        let mut ret: Vec<&OsStr> = vec![];

        if let Some(log_argument) = self.log_level.to_argument() {
            ret.push(log_argument);
        }

        if let Some(ref attr) = self.attribute {
            ret.push(OsStr::new("-A"));
            ret.push(OsStr::new(attr));
        }

        for (name, value) in self.argstrs.iter() {
            ret.push(OsStr::new("--argstr"));
            ret.push(OsStr::new(name));
            ret.push(OsStr::new(value));
        }

        match self.input {
            Input::Expression(ref exp) => {
                ret.push(OsStr::new("--expr"));
                ret.push(OsStr::new(exp.as_str()));
            }
            Input::File(ref fp) => {
                ret.push(OsStr::new("--"));
                ret.push(OsStr::new(fp));
            }
        }

        ret
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
    use super::{CallOpts, LogLevel};
    use std::ffi::OsStr;
    use std::path::PathBuf;

    #[test]
    fn cmd_arguments_expression() {
        let mut nix = CallOpts::expression("my-cool-expression");
        nix.attribute("hello");
        nix.argstr("foo", "bar");

        let exp: Vec<&OsStr> = [
            "-A",
            "hello",
            "--argstr",
            "foo",
            "bar",
            "--expr",
            "my-cool-expression",
        ]
        .into_iter()
        .map(OsStr::new)
        .collect();
        assert_eq!(exp, nix.command_arguments());
    }

    #[test]
    fn cmd_arguments_test() {
        let mut nix2 = CallOpts::file(PathBuf::from("/my-cool-file.nix"));
        nix2.attribute("hello");
        nix2.argstr("foo", "bar");
        let exp2: Vec<&OsStr> = [
            "-A",
            "hello",
            "--argstr",
            "foo",
            "bar",
            "--",
            "/my-cool-file.nix",
        ]
        .into_iter()
        .map(OsStr::new)
        .collect();
        assert_eq!(exp2, nix2.command_arguments());
    }

    #[test]
    fn cmd_arguments_loglevel() {
        let mut nix2 = CallOpts::file(PathBuf::from("/my-cool-file.nix"));
        nix2.attribute("hello");
        nix2.argstr("foo", "bar");
        nix2.log_level(LogLevel::ErrorsOnly);
        let exp2: Vec<&OsStr> = [
            "-q",
            "-A",
            "hello",
            "--argstr",
            "foo",
            "bar",
            "--",
            "/my-cool-file.nix",
        ]
        .into_iter()
        .map(OsStr::new)
        .collect();
        assert_eq!(exp2, nix2.command_arguments());
    }
}
