use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;
use std::collections::HashSet;

#[test]
fn bug97_varmap_leak() {
    let mut testcase = DirenvTestCase::new("bug97_varmap_leak");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();
    let keys: HashSet<String> = env.keys().cloned().collect();
    let expect: HashSet<String> = vec![
        "name",
        "out",
        "origBuilder",
        "origArgs",
        "origOutputs",
        "stdenv",
        "NIX_BUILD_CORES",
        "PATH",
        // Direnv State Vars
        "DIRENV_DIFF",
        "DIRENV_DIR",
        "DIRENV_WATCHES",
    ]
    .into_iter()
    .map(str::to_string)
    .collect();
    assert_eq!(keys, expect);
}
