extern crate lorri;
extern crate structopt;
#[macro_use]
extern crate log;

use lorri::cli::{Arguments, Command};
use lorri::ops::{
    build, daemon, direnv, info, init, ping, shell, upgrade, watch, ExitError, OpResult,
};
use lorri::project::{Project, ProjectLoadError};
use std::env;
use structopt::StructOpt;

const TRIVIAL_SHELL_SRC: &str = include_str!("./trivial-shell.nix");
const DEFAULT_ENVRC: &str = "eval \"$(lorri direnv)\"";

fn main() {
    let opts = Arguments::from_args();

    lorri::logging::init_with_default_log_level(opts.verbosity);
    debug!("Input options: {:?}", opts);

    let project = Project::from_cwd();

    let result: OpResult = match (opts.command, project) {
        (Command::Info, Ok(project)) => info::main(&project),

        (Command::Build, Ok(project)) => build::main(&project),

        (Command::Direnv, Ok(project)) => direnv::main(&project),

        (Command::Shell, Ok(project)) => shell::main(project),

        (Command::Watch, Ok(project)) => watch::main(&project),

        (Command::Daemon, Ok(_project)) => daemon::main(),

        // TODO: remove
        (Command::Ping(p), Ok(_project)) => ping::main(p.nix_file),

        (Command::Upgrade(args), _) => upgrade::main(args),

        (Command::Init, _) => init::main(TRIVIAL_SHELL_SRC, DEFAULT_ENVRC),

        (_, Err(ProjectLoadError::ConfigNotFound)) => {
            let current_dir_msg = match env::current_dir() {
                Err(_) => String::from(""),
                Ok(pb) => format!(" ({})", pb.display()),
            };

            ExitError::errmsg(format!(
                "There is no `shell.nix` in the current directory{}
You can use the following minimal `shell.nix` to get started:

{}",
                current_dir_msg, TRIVIAL_SHELL_SRC
            ))
        }

        (cmd, Err(err)) => ExitError::errmsg(format!(
            "Can't run {:?}, because of the following project load error: {:?}",
            cmd, err
        )),
    };

    match result {
        Err(err) => {
            eprintln!("{}", err.message());
            std::process::exit(err.exitcode());
        }
        Ok(Some(msg)) => {
            println!("{}", msg);
            std::process::exit(0);
        }
        Ok(None) => {
            std::process::exit(0);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Try instantiating the trivial shell file we provide the user.
    #[test]
    fn trivial_shell_nix() -> std::io::Result<()> {
        let out = std::process::Command::new("nix-instantiate")
            .args(&["--expr", TRIVIAL_SHELL_SRC])
            .output()?;
        assert!(
            out.status.success(),
            "stdout:\n{}\nstderr:{}\n",
            std::str::from_utf8(&out.stdout).unwrap(),
            std::str::from_utf8(&out.stderr).unwrap()
        );
        Ok(())

        // TODO: provide .instantiate(), which does a plain nix-instantiate
        // and returns the .drv file.
        // let res = nix::CallOpts::expression(TRIVIAL_SHELL_SRC)
        //     .instantiate();

        // match res {
        //     Ok(_drv) => Ok(()),
        //     Err(nix::InstantiateError::ExecutionFailed(output)) =>
        //         panic!(
        //             "stdout:\n{}\nstderr:{}\n",
        //             std::str::from_utf8(&output.stdout).unwrap(),
        //             std::str::from_utf8(&output.stderr).unwrap()
        //         ),
        //     Err(nix::InstantiateError::Io(io)) => Err(io)
        // }
    }
}
