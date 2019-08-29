use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;

#[test]
fn trivial() -> std::io::Result<()> {
    let mut testcase = DirenvTestCase::new("basic");
    let res = testcase.evaluate().expect("Failed to build the first time");

    assert!(
        res.output_paths.all_exist(),
        "no build output (build-0) in {}.\nContents of {}\n{}",
        res.output_paths.shell_gc_root,
        testcase.cachedir.path().display(),
        std::str::from_utf8(
            &std::process::Command::new("ls")
                .args(&["-la", "--recursive"])
                .args(&[testcase.cachedir.path().as_os_str()])
                .output()?
                .stdout
        )
        .unwrap()
    );

    let env = testcase.get_direnv_variables();
    assert_eq!(env.get_env("MARKER"), DirenvValue::Value("present"));
    Ok(())
}
