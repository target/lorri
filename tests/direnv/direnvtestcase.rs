//! Implement a wrapper around setup and tear-down of Direnv-based test
//! cases.

use lorri::{
    build_loop::{BuildError, BuildLoop, BuildResults},
    ops::direnv,
    project::Project,
    roots::Roots,
};
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use std::process::Command;
use tempfile::{tempdir, TempDir};

pub struct DirenvTestCase {
    tempdir: TempDir,
    project: Project,
    build_loop: BuildLoop,
}

impl DirenvTestCase {
    pub fn new(name: &str) -> DirenvTestCase {
        let tempdir = tempdir().expect("tempfile::tempdir() failed us!");

        let test_root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("tests")
            .join("direnv")
            .join(name);

        let project =
            Project::load(test_root.join("shell.nix"), tempdir.path().to_path_buf()).unwrap();

        let build_loop =
            BuildLoop::new(project.expression(), Roots::from_project(&project).unwrap());

        DirenvTestCase {
            tempdir,
            project,
            build_loop,
        }
    }

    /// Execute the build loop one time
    pub fn evaluate(&mut self) -> Result<BuildResults, BuildError> {
        self.build_loop.once()
    }

    /// Run `direnv allow` and then `direnv export json`, and return
    /// the environment DirEnv would produce.
    pub fn get_direnv_variables(&self) -> DirenvEnv {
        let shell = direnv::main(&self.project)
            .unwrap()
            .expect("direnv::main should return a string of shell");

        File::create(self.project.project_root.join(".envrc"))
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
        let result = env.output().expect("Failed to run direnv allow");
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
        d.env("DIRENV_CONFIG", &self.tempdir.path());
        d.env("XDG_CONFIG_HOME", &self.tempdir.path());
        d.current_dir(&self.project.project_root);

        d
    }
}

/// The resulting environment Direnv after running Direnv. Note:
/// Direnv returns `{ "varname": null, "varname": "something" }`
/// so the value type is `Option<String>`. This makes `.get()`
/// operations clunky, so be prepared to check for `Some(None)` and
/// `Some(Some("val"))`.
#[derive(Deserialize, Debug)]
pub struct DirenvEnv(HashMap<String, Option<String>>);

impl DirenvEnv {
    /// Get an environment value with a borrowed str in the deepest Option.
    /// Makes asserts nicer, like:
    ///
    ///    assert!(env.get_env("foo"), Value("bar"));
    pub fn get_env<'a, 'b>(&'a self, key: &'b str) -> DirenvValue {
        match self.0.get(key) {
            Some(Some(val)) => DirenvValue::Value(&val),
            Some(None) => DirenvValue::Unset,
            None => DirenvValue::NotSet,
        }
    }
}

/// Environemnt Values from Direnv
#[derive(Debug, PartialEq)]
pub enum DirenvValue<'a> {
    /// This variable will not be modified.
    NotSet,

    /// This variable will be unset when entering direnv.
    Unset,

    /// This variable will be set to exactly.
    Value(&'a str),
}
