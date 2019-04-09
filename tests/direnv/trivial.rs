use direnvtestcase::{DirenvTestCase, DirenvValue};

#[test]
fn trivial() {
    let mut testcase = DirenvTestCase::new("basic");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();
    assert_eq!(env.get_env("MARKER"), DirenvValue::Value("present"));
}
