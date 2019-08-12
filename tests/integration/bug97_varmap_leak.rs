use direnv::DirenvValue;
use direnvtestcase::DirenvTestCase;
use std::collections::HashSet;

#[test]
fn bug97_varmap_leak() {
    let mut testcase = DirenvTestCase::new("bug97_varmap_leak");
    testcase.evaluate().expect("Failed to build the first time");

    let env = testcase.get_direnv_variables();

    assert_eq!(env.get_env("preHook"), DirenvValue::Value("echo 'foo bar'"));

    let mut found_env_keys: HashSet<String> = env.keys().cloned().collect();

    vec![
        // Scenario-specific variables
        "preHook",
        // Nix derivation variables
        "name",
        "builder",
        "out",
        "stdenv",
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
    ]
    .into_iter()
    .for_each(|okay_var| {
        found_env_keys.remove(okay_var);
    });

    assert_eq!(found_env_keys, HashSet::new());
}
