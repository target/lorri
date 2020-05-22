//! Helper command to create a user shell

use crate::cas::ContentAddressable;
use crate::cli::StartUserShellOptions_;
use crate::ops::error::OpResult;
use crate::project::Project;
use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::Command;
use std::{env, fs};

/// See the documentation for `crate::ops::shell::main`.
pub fn main(project: Project, opts: StartUserShellOptions_) -> OpResult {
    // This temporary directory will not be cleaned up by lorri because we exec into the shell
    // process, which means that destructors will not be run. However, (1) the temporary files
    // lorri creates in this directory are only a few hundred bytes long; (2) the directory will be
    // cleaned up on reboot or whenever the OS decides to purge temporary directories.
    let tempdir = tempfile::tempdir().expect("failed to create temporary directory");
    let e = shell_cmd(opts.shell_path.as_ref(), &project.cas, tempdir.path()).exec();

    // 'exec' will never return on success, so if we get here, we know something has gone wrong.
    panic!("failed to exec into '{}': {}", opts.shell_path.display(), e);
}

fn shell_cmd(shell_path: &Path, cas: &ContentAddressable, tempdir: &Path) -> Command {
    let mut cmd = Command::new(shell_path);

    match shell_path
        .file_name()
        .expect("shell path must point to a file")
        .to_str()
        .expect("shell path is not UTF-8 clean")
    {
        "bash" => {
            // To override the prompt, we need to set PS1 *after* all other setup scripts have run.
            // That makes it necessary to create our own setup script to be passed via --rcfile.
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
        "zsh" => {
            // Zsh does not support anything like bash's --rcfile. However, zsh sources init
            // scripts from $ZDOTDIR by default. So we set $ZDOTDIR to a directory under lorri's
            // control, follow the default sourcing procedure, and then set the PS1.
            fs::write(
                tempdir.join(".zshrc"),
                // See "STARTUP/SHUTDOWN FILES" section of the zshall man page as well as
                // https://superuser.com/a/591440/318156.
                r#"
unset RCS # disable automatic sourcing of startup scripts

# reset ZDOTDIR
if [ ! -z ${ZDOTDIR_BEFORE} ]; then
    ZDOTDIR="${ZDOTDIR_BEFORE}"
else
    unset ZDOTDIR
fi

ZDOTDIR_OR_HOME="${ZDOTDIR:-${HOME}}"
test -f "$ZDOTDIR_OR_HOME/.zshenv" && . "$ZDOTDIR_OR_HOME/.zshenv"
test -f "/etc/zshrc"               && . "/etc/zshrc"
ZDOTDIR_OR_HOME="${ZDOTDIR:-${HOME}}"
test -f "$ZDOTDIR_OR_HOME/.zshrc"  && . "$ZDOTDIR_OR_HOME/.zshrc"

PS1="(lorri) ${PS1}"
"#,
            )
            .expect("failed to write zsh init script");
            if let Ok(d) = env::var("ZDOTDIR") {
                cmd.env("ZDOTDIR_BEFORE", d);
            }
            cmd.env("ZDOTDIR", tempdir);
        }
        // Add handling for other supported shells here.
        _ => {}
    }
    cmd
}
