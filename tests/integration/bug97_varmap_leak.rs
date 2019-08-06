use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;

#[test]
fn bug97_varmap_leak() {
    let mut testcase = DirenvTestCase::new("bug97_varmap_leak");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();
    println!("{:?}", env);
    assert_eq!(env.get_env("preHook"), DirenvValue::NotSet);
}
