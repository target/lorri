use lorri::{cas::ContentAddressable, ops::shell, project::Project, NixFile};
use std::fs;
use std::iter::FromIterator;
use std::path::{Path, PathBuf};

#[test]
fn loads_env() {
    let tempdir = tempfile::tempdir().expect("tempfile::tempdir() failed us!");
    let project = project("loads_env", tempdir.path());
    let (init_file, mut shell) = shell::bash(project, tempdir.path()).unwrap();

    // In `shell::main`, bash is run interactively. In interactive mode, bash respects the
    // `--init-file` option, so that is what we use there to load the init file.
    // Here, we're running bash non-interactively (since we're passing `-c`). When running
    // non-interactively, bash ignores the `--init-file` option. As a result, we need to use the
    // `BASH_ENV` environment variable to ensure that the init file is sourced at startup.
    let output = shell
        .env(
            "BASH_ENV",
            init_file
                .to_str()
                .expect("script file path not UTF-8 clean"),
        )
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
