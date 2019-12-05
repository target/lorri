extern crate lorri;
extern crate structopt;
#[macro_use]
extern crate human_panic;

use lorri::cli::{Arguments, Command};
use lorri::constants;
use lorri::locate_file;
use lorri::logging;
use lorri::ops::error::{ExitError, OpResult};
use lorri::ops::{daemon, direnv, info, init, ping, upgrade, watch};
use lorri::project::Project;
use lorri::NixFile;
use slog::{debug, error};
use std::path::PathBuf;
use structopt::StructOpt;

const TRIVIAL_SHELL_SRC: &str = include_str!("./trivial-shell.nix");
const DEFAULT_ENVRC: &str = "eval \"$(lorri direnv)\"";

fn main() {
    // This returns 101 on panics, see also `ExitError::panic`.
    setup_panic!();

    let exit_code = {
        let opts = Arguments::from_args();

        // This logger is asynchronous. It is guaranteed to be flushed upon destruction. By tying
        // its lifetime to this smaller scope, we ensure that it is destroyed before
        // 'std::process::exit' gets called.
        let log = logging::root(opts.verbosity, &opts.command);
        debug!(log, "input options"; "options" => format!("{:?}", opts));

        match run_command(log.clone(), opts) {
            Err(err) => {
                error!(log, "{}", err.message());
                err.exitcode()
            }
            Ok(()) => 0,
        }
    };

    // TODO: Once the 'Termination' trait has been stabilised, 'OpResult' should implement
    // 'Termination' and 'main' should return 'OpResult'.
    // https://doc.rust-lang.org/std/process/trait.Termination.html
    // https://github.com/rust-lang/rfcs/blob/master/text/1937-ques-in-main.md
    std::process::exit(exit_code);
}

/// Try to read `shell.nix` from the current working dir.
fn get_shell_nix(shellfile: &PathBuf) -> Result<NixFile, ExitError> {
    // use shell.nix from cwd
    Ok(NixFile::from(locate_file::in_cwd(&shellfile).map_err(
        |_| {
            ExitError::user_error(format!(
                "`{}` does not exist\n\
                 You can use the following minimal `shell.nix` to get started:\n\n\
                 {}",
                shellfile.display(),
                TRIVIAL_SHELL_SRC
            ))
        },
    )?))
}

fn create_project(paths: &constants::Paths, shell_nix: NixFile) -> Result<Project, ExitError> {
    Project::new(shell_nix, &paths.gc_root_dir(), paths.cas_store().clone()).or_else(|e| {
        Err(ExitError::temporary(format!(
            "Could not set up project paths: {:#?}",
            e
        )))
    })
}

/// Run the main function of the relevant command.
fn run_command(log: slog::Logger, opts: Arguments) -> OpResult {
    let paths = lorri::ops::get_paths()?;
    let project = opts
        .command
        .nix_file()
        .map(get_shell_nix)
        .transpose()?
        .map(|nix_file| create_project(&paths, nix_file))
        .transpose()?;
    let log = project
        .as_ref()
        .map(|p| p.nix_file.clone())
        .map_or(log.clone(), |root| log.new(slog::o!("root" => root)));
    let _guard = slog_scope::set_global_logger(log);
    match opts.command {
        Command::Info(_opts) => info::main(project.unwrap()),
        Command::Direnv(_opts) => {
            direnv::main(project.unwrap(), /* shell_output */ std::io::stdout())
        }
        Command::Watch(opts) => watch::main(project.unwrap(), opts),
        Command::Daemon => daemon::main(),
        Command::Upgrade(opts) => upgrade::main(opts, paths.cas_store()),
        // TODO: remove
        Command::Ping_(opts) => get_shell_nix(&opts.nix_file).and_then(ping::main),
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
            // we can’t assume to have a <nixpkgs>, so use bogus-nixpkgs
            .args(&["-I", "nixpkgs=./nix/bogus-nixpkgs/"])
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
