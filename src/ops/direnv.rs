//! Emit shell script intended to be evaluated as part of direnv's .envrc

use crate::ops::OpResult;
use crate::project::Project;

/// See the documentation for lorri::cli::Command::Direnv for more
/// details.
pub fn main(project: Project) -> OpResult {
    let mut shell_root = project.gc_root_path().unwrap();
    shell_root.push("build-0"); // !!!

    println!(
        r#"
EVALUATION_ROOT="{}"

{}
"#,
        shell_root.display(),
        include_str!("envrc.bash")
    );

    Ok(())
}
