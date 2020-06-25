use crate::direnvtestcase::{DirenvTestCase, DirenvValue};
use std::time::{Duration, Instant};

#[test]
fn not_so_slow() {
    let mut testcase = DirenvTestCase::new("bug110_duplicate_appends");
    testcase.evaluate().expect("Failed to build the first time");

    let start = Instant::now();
    let env = testcase.get_direnv_variables();
    println!("direnv time: {:?}", start.elapsed());
    assert!(
        start.elapsed() < Duration::from_secs(2),
        "direnv export should be under 2 seconds (even on CI)"
    );
    let itworked = env.get_env("ITWORKED");
    assert!(
        match itworked {
            DirenvValue::Value(v) => v.ends_with("foo/bar"),
            _ => false,
        },
        format!("ITWORKED shoud end with 'foo/bar', but is {:?}", itworked)
    )
}
