use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;
use std::env;

#[test]
fn bug23_shell_hook() {
    env::set_var("EXAMPLE", "my-neat-path");
    let mut testcase = DirenvTestCase::new("bug23_setuphook");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();
    println!("{:?}", env);
    assert_eq!(
        env.get_env("EXAMPLE"),
        DirenvValue::Value("my-neat-path:/tmp/foo/bar")
    );
}
