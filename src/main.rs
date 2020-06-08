use lorri::cli::{Arguments, Command, Internal_};
use lorri::constants;
use lorri::locate_file;
use lorri::logging;
use lorri::ops::error::{ExitError, OpResult};
use lorri::ops::{
    daemon, direnv, info, init, ping, shell, start_user_shell, stream_events, upgrade, watch,
};
use lorri::project::Project;
use lorri::NixFile;
use slog::{debug, error, o};
use slog_scope::GlobalLoggerGuard;
use std::path::PathBuf;
use structopt::StructOpt;

const TRIVIAL_SHELL_SRC: &str = include_str!("./trivial-shell.nix");
const DEFAULT_ENVRC: &str = "eval \"$(lorri direnv)\"\n";

fn main() {
    // This returns 101 on panics, see also `ExitError::panic`.
    human_panic::setup_panic!();

    let exit_code = {
        let opts = Arguments::from_args();

        // This logger is asynchronous. It is guaranteed to be flushed upon destruction. By tying
        // its lifetime to this smaller scope, we ensure that it is destroyed before
        // 'std::process::exit' gets called.
        let log = logging::root(opts.verbosity, &opts.command);
        debug!(log, "input options"; "options" => ?opts);

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
    Ok(NixFile::Shell(locate_file::in_cwd(&shellfile).map_err(
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

    // `without_project` and `with_project` set up the slog_scope global logger. Make sure to use
    // one of them so the logger gets set up correctly.
    let without_project = || slog_scope::set_global_logger(log.clone());
    let with_project = |nix_file| -> std::result::Result<(Project, GlobalLoggerGuard), ExitError> {
        let project = create_project(&lorri::ops::get_paths()?, get_shell_nix(nix_file)?)?;
        let guard = slog_scope::set_global_logger(log.new(o!("expr" => project.nix_file.clone())));
        Ok((project, guard))
    };

    match opts.command {
        Command::Info(opts) => {
            let (project, _guard) = with_project(&opts.nix_file)?;
            info::main(project)
        }
        Command::Direnv(opts) => {
            let (project, _guard) = with_project(&opts.nix_file)?;
            direnv::main(project, /* shell_output */ std::io::stdout())
        }
        Command::Shell(opts) => {
            let (project, _guard) = with_project(&opts.nix_file)?;
            shell::main(project, opts)
        }

        Command::Watch(opts) => {
            let (project, _guard) = with_project(&opts.nix_file)?;
            watch::main(project, opts)
        }
        Command::Daemon(opts) => {
            let _guard = without_project();
            daemon::main(opts)
        }
        Command::Upgrade(opts) => {
            let _guard = without_project();
            upgrade::main(opts, paths.cas_store())
        }
        Command::Init => {
            let _guard = without_project();
            init::main(TRIVIAL_SHELL_SRC, DEFAULT_ENVRC)
        }

        Command::Internal { command } => match command {
            Internal_::Ping_(opts) => {
                let _guard = without_project();
                get_shell_nix(&opts.nix_file).and_then(ping::main)
            }
            Internal_::StartUserShell_(opts) => {
                let (project, _guard) = with_project(&opts.nix_file)?;
                start_user_shell::main(project, opts)
            }
            Internal_::StreamEvents_(se) => {
                let _guard = without_project();
                stream_events::main(se.kind)
            }
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    /// Try instantiating the trivial shell file we provide the user.
    #[test]
    fn trivial_shell_nix() -> std::io::Result<()> {
        let nixpkgs = "./nix/bogus-nixpkgs/";

        // Sanity check the test environment
        assert!(Path::new(nixpkgs).is_dir(), "nixpkgs must be a directory");
        assert!(
            Path::new(nixpkgs).join("default.nix").is_file(),
            "nixpkgs/default.nix must be a file"
        );

        let out = std::process::Command::new("nix-instantiate")
            // we can’t assume to have a <nixpkgs>, so use bogus-nixpkgs
            .args(&["-I", &format!("nixpkgs={}", nixpkgs)])
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
