use lorri::{cas::ContentAddressable, ops::shell, project::Project, NixFile};
use std::fs;
use std::iter::FromIterator;
use std::path::{Path, PathBuf};

#[test]
fn loads_env() {
    let tempdir = tempfile::tempdir().expect("tempfile::tempdir() failed us!");
    let project = project("loads_env", tempdir.path());
    let output = shell::bash_cmd(project, tempdir.path())
        .unwrap()
        .args(&["-c", "echo $MY_ENV_VAR"])
        .output()
        .expect("failed to run shell");

    assert_eq!(
        // The string conversion means we get a nice assertion failure message in case stdout does
        // not match what we expected.
        String::from_utf8(output.stdout).expect("stdout not UTF-8 clean"),
        "my_env_value\n"
    );
}

fn project(name: &str, cache_dir: &Path) -> Project {
    let test_root = PathBuf::from_iter(&[env!("CARGO_MANIFEST_DIR"), "tests", "shell", name]);
    let cas_dir = cache_dir.join("cas").to_owned();
    fs::create_dir_all(&cas_dir).expect("failed to create CAS directory");
    Project::new(
        NixFile::Shell(test_root.join("shell.nix")),
        &cache_dir.join("gc_roots").to_owned(),
        ContentAddressable::new(cas_dir).unwrap(),
    )
    .unwrap()
}
