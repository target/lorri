//! Helpers for working with inline Bash, in particular for tests.

use std::ffi::OsStr;
use std::process::Command;

/// Command must be static because it guarantees there is no user
/// interpolation of shell commands.
///
/// The command string is intentionally difficult to interpolate code
/// in to, for safety. Instead, pass variable arguments in `args` and
/// refer to them as `"$1"`, `"$2"`, etc.
///
/// Watch your quoting, though, as you can still hurt yourself there.
///
/// # Examples
///
///     use lorri::bash::expect_bash;
///
///     expect_bash(r#"exit "$1""#, &["0"]);
///
/// Make sure to properly quote your variables in the command string,
/// so bash can properly escape your code. This is safe, despite the
/// attempt at pwning my machine:
///
///     use lorri::bash::expect_bash;
///
///     expect_bash(r#"echo "$1""#, &[r#"hi"; touch ./pwnd"#]);
///
pub fn expect_bash<I, S>(command: &'static str, args: I)
where
    I: IntoIterator<Item = S> + std::fmt::Debug,
    S: AsRef<OsStr>,
{
    let ret = Command::new("bash")
        .args(&["-euc", command, "--"])
        .args(args)
        .status()
        .expect("bash should start properly, regardless of exit code");

    if !ret.success() {
        panic!("{:#?}", ret);
    }
}

#[cfg(test)]
mod tests {
    use super::expect_bash;

    #[test]
    #[should_panic]
    fn expect_bash_can_fail() {
        expect_bash(r#"exit "$1""#, &["1"]);
    }

    #[test]
    fn expect_bash_can_pass() {
        expect_bash(r#"exit "$1""#, &["0"]);
    }
}
