//! Helper command to create a user shell

use crate::cas::ContentAddressable;
use crate::cli::StartUserShellOptions_;
use crate::ops::error::OpResult;
use crate::project::Project;
use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::Command;

/// See the documentation for `crate::ops::shell::main`.
pub fn main(project: Project, opts: StartUserShellOptions_) -> OpResult {
    let e = shell_cmd(opts.shell_path.as_ref(), &project.cas).exec();

    // 'exec' will never return on success, so if we get here, we know something has gone wrong.
    panic!("failed to exec into '{}': {}", opts.shell_path.display(), e);
}

fn shell_cmd(shell_path: &Path, cas: &ContentAddressable) -> Command {
    let mut cmd = Command::new(shell_path);

    #[allow(clippy::single_match)] // only bash is currently handled
    match shell_path
        .file_name()
        .expect("shell path must point to a file")
        .to_str()
        .expect("shell path is not UTF-8 clean")
    {
        "bash" => {
            // In order to be able to override the prompt, we need to set PS1 *after* all other
            // setup scripts have run. That makes it necessary to create our own setup script to be
            // passed via --rcfile, which first sources all other setup scripts and then sets PS1.
            let rcfile = cas
                .file_from_string(
                    // Using --rcfile disables sourcing of default setup scripts, so we source them
                    // explicitly here.
                    r#"
[ -e /etc/bash.bashrc ] && . /etc/bash.bashrc
[ -e ~/.bashrc ] && . ~/.bashrc
PS1="(lorri) $PS1"
"#,
                )
                .expect("failed to write bash init script");
            cmd.args(&[
                "--rcfile",
                rcfile.to_str().expect("file path not UTF-8 clean"),
            ]);
        }
        // TODO: add handling for other supported shells here.
        _ => {}
    }
    cmd
}
