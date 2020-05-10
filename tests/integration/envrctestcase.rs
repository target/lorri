//! Implement a wrapper around setup and tear-down of Direnv-based test
//! cases.

use crate::direnv::DirenvEnv;
use std::collections::HashMap;
use std::ffi::{OsStr, OsString};
use std::fmt::Display;
use std::fs::{create_dir, File};
use std::io::BufWriter;
use std::io::Write;
use std::os::unix::ffi::OsStrExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use tempfile::{tempdir, TempDir};

fn find_program<S: Display + AsRef<OsStr>>(program: S) -> PathBuf {
    // Find programs: the environment variables in tests very likely
    // makes PATH bogus.
    let output = Command::new("bash")
        .args(&["-c", "type -p \"$1\"", "--"])
        .arg(&program)
        .output()
        .expect(&format!("Failed to execute «bash -c 'which {}'»", &program));

    assert!(
        output.status.success(),
        format!("Calling «bash -c 'which {}'» failed!", &program)
    );

    let location = String::from_utf8(output.stdout).expect(&format!(
        "Found «{}», but the output is not utf8 clean.",
        &program
    ));

    PathBuf::from(location.trim())
}

pub trait ProjectEnv {
    fn write_to(&self, destination: &Path) -> Result<(), std::io::Error>;
}

pub struct ProjectEnvBuilderV1 {
    env_vars: HashMap<OsString, OsString>,
}

impl ProjectEnvBuilderV1 {
    pub fn new() -> ProjectEnvBuilderV1 {
        ProjectEnvBuilderV1 {
            env_vars: HashMap::new(),
        }
    }

    pub fn set<S: Into<OsString>>(mut self, env_var: S, value: S) -> Self {
        self.env_vars.insert(env_var.into(), value.into());
        self
    }
}

impl ProjectEnv for ProjectEnvBuilderV1 {
    fn write_to(&self, destination: &Path) -> Result<(), std::io::Error> {
        // Command::new searches the PATH, but since we
        // .clear_env(), we must manually `find_program` ahead of
        // time.
        let output = Command::new(find_program("bash"))
            .args(&["-c", "export"])
            .env_clear()
            .envs(self.env_vars.iter())
            .output()
            .expect("Failed to execute bash -c export");

        assert!(
            output.status.success(),
            "Calling «bash -c 'export'» failed!"
        );

        File::create(destination)?.write_all(&output.stdout)?;

        Ok(())
    }
}

pub struct ProjectEnvBuilderV2 {
    set: HashMap<OsString, OsString>,
    append: HashMap<OsString, OsString>,
}

impl ProjectEnvBuilderV2 {
    pub fn new() -> ProjectEnvBuilderV2 {
        ProjectEnvBuilderV2 {
            set: HashMap::new(),
            append: HashMap::new(),
        }
    }

    pub fn set<S: Into<OsString>>(mut self, env_var: S, value: S) -> Self {
        self.set.insert(env_var.into(), value.into());
        self
    }

    pub fn append<S: Into<OsString>>(mut self, env_var: S, separator: S, value: S) -> Self {
        let env_var = env_var.into();
        let value = value.into();
        self.set.insert(env_var.clone(), value.clone());
        self.append.insert(env_var, separator.into());
        self
    }
}

impl ProjectEnv for ProjectEnvBuilderV2 {
    fn write_to(&self, destination: &Path) -> Result<(), std::io::Error> {
        let output = Command::new(find_program("bash"))
            .args(&["-c", "export"])
            .env_clear()
            .envs(self.set.iter())
            .output()
            .expect("Failed to execute bash -c export");

        assert!(
            output.status.success(),
            "Calling «bash -c 'export'» failed!"
        );

        create_dir(&destination)?;

        File::create(&destination.join("bash-export"))?.write_all(&output.stdout)?;

        let mut writer = BufWriter::new(File::create(&destination.join("varmap-v1"))?);
        for (variable, separator) in self.append.iter() {
            writer.write_all(b"append").unwrap();
            writer.write_all(b"\0").unwrap();
            writer.write_all(&variable.as_bytes()).unwrap();
            writer.write_all(b"\0").unwrap();
            writer.write_all(separator.as_bytes()).unwrap();
            writer.write_all(b"\0").unwrap();
        }

        Ok(())
    }
}

pub struct EnvrcTestCase {
    tempdir: TempDir,
    ambient_env: HashMap<OsString, OsString>,
    project_env: Option<PathBuf>,
}

impl EnvrcTestCase {
    pub fn new() -> EnvrcTestCase {
        let tempdir = tempdir().expect("tempfile::tempdir() failed us!");

        EnvrcTestCase {
            tempdir,
            ambient_env: HashMap::new(),
            project_env: None,
        }
    }

    pub fn ambient_env<S: Into<OsString>>(&mut self, env_var: S, value: S) -> &mut Self {
        self.ambient_env.insert(env_var.into(), value.into());
        self
    }

    pub fn project_env<P: ProjectEnv>(
        &mut self,
        project_env: P,
    ) -> Result<&mut Self, std::io::Error> {
        let dest = self.tempdir.path().join("project-env");
        project_env.write_to(&dest)?;
        self.project_env = Some(dest);
        Ok(self)
    }

    /// Run `direnv allow` and then `direnv export json`, and return
    /// the environment DirEnv would produce.
    pub fn get_direnv_variables(&self) -> DirenvEnv {
        let root = self.tempdir.path().join("test-root");
        create_dir(&root).expect("creating test-root directory");

        File::create(root.join(".envrc"))
            .expect("creating .envrc")
            .write_all(include_bytes!("../../src/ops/direnv/envrc.bash"))
            .expect("Writing envrc.bash to test-root's .envrc");

        {
            let mut allow = self.direnv_cmd();
            allow.arg("allow");
            allow.current_dir(&root);
            let result = allow.output().expect("Failed to run direnv allow");
            println!("{:?}", result);
            assert!(result.status.success());
        }

        let mut env = self.direnv_cmd();
        env.args(&["export", "json"]);
        env.current_dir(&root);
        let result = env.output().expect("Failed to run direnv allow");
        println!("{:?}", result);
        assert!(result.status.success());

        serde_json::from_slice(&result.stdout).unwrap()
    }

    fn direnv_cmd(&self) -> Command {
        let mut d = Command::new("direnv");
        d.env_clear();
        // From: https://github.com/direnv/direnv/blob/1423e495c54de3adafde8e26218908010c955514/test/direnv-test.bash
        d.env("DIRENV_CONFIG", &self.tempdir.path());
        d.env("XDG_CONFIG_HOME", &self.tempdir.path());
        d.env("XDG_DATA_HOME", &self.tempdir.path());
        d.envs(self.ambient_env.iter());
        if let Some(ref env) = self.project_env {
            d.env("EVALUATION_ROOT", env);
        } else {
            panic!("lmao waht");
        }

        d
    }
}
