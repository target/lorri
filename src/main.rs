extern crate lorri;
extern crate structopt;
#[macro_use]
extern crate log;

use lorri::constants;
use lorri::locate_file;
use lorri::NixFile;

use lorri::cli::{Arguments, Command};
use lorri::ops::{daemon, direnv, info, init, ping, upgrade, watch, ExitError, OpResult};
use lorri::project::Project;
use std::env;
use structopt::StructOpt;

const TRIVIAL_SHELL_SRC: &str = include_str!("./trivial-shell.nix");
const DEFAULT_ENVRC: &str = "eval \"$(lorri direnv)\"";

fn main() {
    let exit = |result: OpResult| match result {
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
    };

    let opts = Arguments::from_args();

    lorri::logging::init_with_default_log_level(opts.verbosity);
    debug!("Input options: {:?}", opts);

    let result = run_command(opts);
    exit(result);
}

/// Try to read `shell.nix` from the current working dir.
fn get_shell_nix() -> Result<NixFile, ExitError> {
    let current_dir_msg = || match env::current_dir() {
        Err(_) => String::from(""),
        Ok(pb) => format!(" ({})", pb.display()),
    };
    // use shell.nix from cwd
    Ok(NixFile::from(locate_file::in_cwd("shell.nix").map_err(
        |_| {
            ExitError::errmsg(format!(
                "There is no `shell.nix` in the current directory{}\n\
                 You can use the following minimal `shell.nix` to get started:\n\n\
                 {}",
                current_dir_msg(),
                TRIVIAL_SHELL_SRC
            ))
        },
    )?))
}

fn create_project(paths: &constants::Paths, shell_nix: NixFile) -> Result<Project, ExitError> {
    Project::new(shell_nix, &paths.gc_root_dir(), paths.cas_store().clone())
        .or_else(|_| Err(ExitError::errmsg("Could not set up project paths")))
}

/// Run the main function of the relevant command.
fn run_command(opts: Arguments) -> OpResult {
    let paths = lorri::ops::get_paths()?;

    match opts.command {
        Command::Info => get_shell_nix().and_then(|sn| info::main(create_project(&paths, sn)?)),

        Command::Direnv => get_shell_nix().and_then(|sn| direnv::main(create_project(&paths, sn)?)),

        Command::Watch => get_shell_nix().and_then(|sn| watch::main(create_project(&paths, sn)?)),

        Command::Daemon => daemon::main(),

        Command::Upgrade(args) => upgrade::main(args, paths.cas_store()),

        // TODO: remove
        Command::Ping_(p) => ping::main(p.nix_file),

        Command::Init => init::main(TRIVIAL_SHELL_SRC, DEFAULT_ENVRC),
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
