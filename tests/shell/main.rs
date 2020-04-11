use lorri::{
    builder,
    cas::ContentAddressable,
    nix::options::NixOptions,
    ops::shell,
    project::{roots::Roots, Project},
    NixFile,
};
use std::env;
use std::fs;
use std::iter::FromIterator;
use std::path::{Path, PathBuf};
use std::process::Command;

fn cargo_bin(name: &str) -> PathBuf {
    env::current_exe()
        .ok()
        .map(|mut path| {
            path.pop();
            if path.ends_with("deps") {
                path.pop();
            }
            path.join(name)
        })
        .unwrap()
}

#[test]
fn loads_env() {
    let tempdir = tempfile::tempdir().expect("tempfile::tempdir() failed us!");
    let project = project("loads_env", tempdir.path());

    // Launch as a real user
    let res = Command::new(cargo_bin("lorri"))
        .args(&[
            "shell",
            "--shell-file",
            PathBuf::from(&project.nix_file)
                .as_os_str()
                .to_str()
                .unwrap(),
        ])
        .current_dir(&tempdir)
        .output()
        .expect("fail to run lorri shell");
    assert!(res.status.success(), "lorri shell command failed");

    let output = shell::bash_cmd(build(&project), &project.cas)
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

fn build(project: &Project) -> PathBuf {
    Path::new(
        Roots::from_project(&project)
            .create_roots(
                builder::run(&project.nix_file, &project.cas, &NixOptions::empty())
                    .unwrap()
                    .result,
            )
            .unwrap()
            .shell_gc_root
            .as_os_str(),
    )
    .to_owned()
}
