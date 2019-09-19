use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;
use std::collections::HashMap;

#[test]
fn bug97_varmap_leak() {
    let mut testcase = DirenvTestCase::new("bug97_varmap_leak");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();

    assert_eq!(env.get_env("preHook"), DirenvValue::Value("echo 'foo bar'"));

    let these_should_exist = vec![
        // Scenario-specific variables
        "preHook",
        // Nix derivation variables
        "name",
        "builder",
        "out",
        "outputs",
        "stdenv",
        "system",
        "PATH",
        "extraClosure",
        // Lorri dependency capture
        "origBuilder",
        "origArgs",
        "origOutputs",
        "origSystem",
        "origPATH",
        "origExtraClosure",
        // Nix-set variables
        "IN_NIX_SHELL",
        "NIX_BUILD_CORES",
        "NIX_BUILD_TOP",
        "NIX_LOG_FD",
        "NIX_STORE",
        "allowSubstitutes",
        "preferLocalBuild",
        // Direnv State Vars
        "DIRENV_DIFF",
        "DIRENV_DIR",
        "DIRENV_WATCHES",
    ];

    let these_are_left = env.retain(|k| !these_should_exist.contains(&k));

    assert_eq!(
        these_are_left,
        HashMap::new(),
        "The environment must be empty! But it had in it:\n{:#?}",
        these_are_left
    );
}
