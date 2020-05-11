use std::iter::FromIterator;
use std::path::PathBuf;

use crate::direnvtestcase::{DirenvTestCase, DirenvValue};

#[test]
fn in_lorri_shell() {
    let mut testcase = DirenvTestCase::new("basic");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();
    let shell = PathBuf::from_iter(&[env!("CARGO_MANIFEST_DIR"), "tests", "integration", "basic"])
        .join("shell.nix");

    assert_eq!(
        env.get_env("IN_LORRI_SHELL"),
        DirenvValue::Value(shell.to_str().unwrap())
    );
}
