//! Implement a wrapper around setup and tear-down of Direnv-based test
//! cases.

use direnv::DirenvEnv;
use lorri::{
    build_loop::{BuildError, BuildLoop, BuildResults},
    cas::ContentAddressable,
    ops::direnv,
    project::Project,
    NixFile,
};
use std::fs::File;
use std::io::Write;
use std::iter::FromIterator;
use std::path::PathBuf;
use std::process::Command;
use tempfile::{tempdir, TempDir};

pub struct DirenvTestCase {
    projectdir: TempDir,
    // only kept around to not delete tempdir
    #[allow(dead_code)]
    pub cachedir: TempDir,
    project: Project,
}

impl DirenvTestCase {
    pub fn new(name: &str) -> DirenvTestCase {
        let projectdir = tempdir().expect("tempfile::tempdir() failed us!");
        let cachedir = tempdir().expect("tempfile::tempdir() failed us!");

        let test_root =
            PathBuf::from_iter(&[env!("CARGO_MANIFEST_DIR"), "tests", "integration", name]);

        let shell_file = NixFile::from(test_root.join("shell.nix"));

        let cas = ContentAddressable::new(cachedir.path().join("cas").to_owned()).unwrap();
        let project = Project::new(
            shell_file.clone(),
            &cachedir.path().join("gc_roots").to_owned(),
            cas,
        )
        .unwrap();

        DirenvTestCase {
            projectdir,
            cachedir,
            project,
        }
    }

    /// Execute the build loop one time
    pub fn evaluate(&mut self) -> Result<BuildResults, BuildError> {
        BuildLoop::new(&self.project).once()
    }

    /// Run `direnv allow` and then `direnv export json`, and return
    /// the environment DirEnv would produce.
    pub fn get_direnv_variables(&self) -> DirenvEnv {
        let shell = direnv::main(self.project.clone())
            .unwrap()
            .expect("direnv::main should return a string of shell");

        File::create(self.projectdir.path().join(".envrc"))
            .unwrap()
            .write_all(shell.as_bytes())
            .unwrap();

        {
            let mut allow = self.direnv_cmd();
            allow.arg("allow");
            let result = allow.status().expect("Failed to run direnv allow");
            assert!(result.success());
        }

        let mut env = self.direnv_cmd();
        env.args(&["export", "json"]);
        let result = env.output().expect("Failed to run direnv export json");
        if !result.status.success() {
            println!("stderr: {}", String::from_utf8_lossy(&result.stderr));
            println!("\n\n\nstdout: {}", String::from_utf8_lossy(&result.stdout));
        }
        assert!(result.status.success());

        serde_json::from_slice(&result.stdout).unwrap()
    }

    fn direnv_cmd(&self) -> Command {
        let mut d = Command::new("direnv");
        // From: https://github.com/direnv/direnv/blob/1423e495c54de3adafde8e26218908010c955514/test/direnv-test.bash
        d.env_remove("DIRENV_BASH");
        d.env_remove("DIRENV_DIR");
        d.env_remove("DIRENV_MTIME");
        d.env_remove("DIRENV_WATCHES");
        d.env_remove("DIRENV_DIFF");
        d.env("DIRENV_CONFIG", &self.projectdir.path());
        d.env("XDG_CONFIG_HOME", &self.projectdir.path());
        d.current_dir(&self.projectdir.path());

        d
    }
}
