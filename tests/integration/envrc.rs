use direnv::DirenvValue;
use envrctestcase::{EnvrcTestCase, ProjectEnvBuilderV1, ProjectEnvBuilderV2};
use std::env;

#[test]
fn trivial_v1() {
    let env = EnvrcTestCase::new()
        .ambient_env("HOME", "/home/alice")
        .ambient_env("USER", "alice")
        .ambient_env("PATH", &env::var("PATH").unwrap())
        .ambient_env("FOOBAR", "BAZ")
        .ambient_env("GOPATH", "FOO")
        .project_env(
            ProjectEnvBuilderV1::new()
                .set("HOME", "/homeless-shelter")
                .set("USER", "nixbld1")
                .set("PATH", "/foo/bar/path")
                .set("FOOBAR", "TUX")
                .set("GOPATH", "BAR"),
        )
        .unwrap()
        .get_direnv_variables();

    println!("{:?}", env);

    assert_eq!(env.get_env("HOME"), DirenvValue::NotSet);
    assert_eq!(env.get_env("USER"), DirenvValue::NotSet);
    assert_eq!(
        env.get_env("PATH"),
        DirenvValue::Value(&format!("/foo/bar/path:{}", env::var("PATH").unwrap()))
    );
    assert_eq!(env.get_env("FOOBAR"), DirenvValue::Value("TUX"));
    assert_eq!(env.get_env("GOPATH"), DirenvValue::Value("BAR"));
}

#[test]
fn trivial_v2() {
    let env = EnvrcTestCase::new()
        .ambient_env("HOME", "/home/alice")
        .ambient_env("USER", "alice")
        .ambient_env("PATH", &env::var("PATH").unwrap())
        .ambient_env("FOOBAR", "BAZ")
        .ambient_env("GOPATH", "FOO")
        .project_env(
            ProjectEnvBuilderV2::new()
                .set("HOME", "/homeless-shelter")
                .set("USER", "nixbld1")
                .set("PATH", "/foo/bar/path")
                .set("FOOBAR", "TUX")
                .append("GOPATH", ":", "BAR"),
        )
        .unwrap()
        .get_direnv_variables();

    println!("{:?}", env);

    assert_eq!(env.get_env("HOME"), DirenvValue::NotSet);
    assert_eq!(env.get_env("USER"), DirenvValue::NotSet);
    assert_eq!(
        env.get_env("PATH"),
        DirenvValue::Value(&format!("/foo/bar/path:{}", env::var("PATH").unwrap()))
    );
    assert_eq!(env.get_env("FOOBAR"), DirenvValue::Value("TUX"));
    assert_eq!(env.get_env("GOPATH"), DirenvValue::Value("FOO:BAR"));
}

#[test]
fn v2_gopath_previously_unset() {
    let env = EnvrcTestCase::new()
        .ambient_env("PATH", &env::var("PATH").unwrap())
        .project_env(ProjectEnvBuilderV2::new().append("GOPATH", ":", "BAR"))
        .unwrap()
        .get_direnv_variables();

    println!("{:?}", env);

    assert_eq!(env.get_env("GOPATH"), DirenvValue::Value("BAR"));
}
