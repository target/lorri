extern crate lorri;
extern crate structopt;
#[macro_use]
extern crate log;

use lorri::locate_file;
use lorri::NixFile;

use lorri::cli::{Arguments, Command};
use lorri::ops::{
    build, daemon, direnv, info, init, ping, shell, upgrade, watch, ExitError, OpResult,
};
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

    match lorri::ops::get_paths() {
        Err(e) => exit(Err(e)),
        Ok(paths) => {
            let current_dir_msg = || match env::current_dir() {
                Err(_) => String::from(""),
                Ok(pb) => format!(" ({})", pb.display()),
            };

            // use shell.nix from cwd
            let result = locate_file::in_cwd("shell.nix")
                .map_err(|_| {
                    ExitError::errmsg(format!(
                        "There is no `shell.nix` in the current directory{}\n\
                         You can use the following minimal `shell.nix` to get started:\n\n\
                         {}",
                        current_dir_msg(),
                        TRIVIAL_SHELL_SRC
                    ))
                })
                .and_then(|shell_nix| {
                    let nix_file = NixFile::from(shell_nix);
                    let project = Project::new(&nix_file, paths.gc_root_dir());

                    match opts.command {
                        Command::Info => info::main(&project),

                        Command::Build => build::main(&project),

                        Command::Direnv => direnv::main(&project),

                        Command::Shell => shell::main(project),

                        Command::Watch => watch::main(&project),

                        Command::Daemon => daemon::main(),

                        Command::Upgrade(args) => upgrade::main(args),

                        // TODO: remove
                        Command::Ping(p) => ping::main(p.nix_file),

                        Command::Init => init::main(TRIVIAL_SHELL_SRC, DEFAULT_ENVRC),
                    }
                });
            exit(result);
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
