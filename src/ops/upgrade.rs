//! Upgrade lorri by using nix-env to install from Git.
//!
//! In the future, this upgrade tool should use tagged versions.
//! However, while this repo is closed source, it uses a
//! rolling-release branch.

use crate::cas::ContentAddressable;
use crate::changelog;
use crate::cli;
use crate::nix;
use crate::ops::error::{ok, ExitError, OpResult};
use crate::VERSION_BUILD_REV;
use slog_scope::info;
use std::path::PathBuf;
use std::process::Command;

/// The source to upgrade to.
enum UpgradeSource {
    /// A branch in the upstream git repo
    Branch(String),
    /// A local path
    Local(PathBuf),
}

enum UpgradeSourceError {
    /// The local path given by the user could not be found
    LocalPathNotFound(PathBuf),
    /// We couldn’t find local_path/release.nix, it is not a lorri repo.
    ReleaseNixDoesntExist(PathBuf),
    /// An other error happened when canonicalizing the given path.
    CantCanonicalizeLocalPath(std::io::Error),
}

impl UpgradeSource {
    /// Convert from the cli argument to a form we can pass to ./upgrade.nix.
    fn from_cli_argument(upgrade_target: cli::UpgradeTo) -> Result<Self, UpgradeSourceError> {
        // if no source was given, we default to the rolling-release branch
        let src = upgrade_target
            .source
            .unwrap_or(cli::UpgradeSource::RollingRelease);
        Ok(match src {
            cli::UpgradeSource::RollingRelease => {
                UpgradeSource::Branch(String::from("rolling-release"))
            }
            cli::UpgradeSource::Master => UpgradeSource::Branch(String::from("master")),
            cli::UpgradeSource::Branch(b) => UpgradeSource::Branch(b.branch),
            cli::UpgradeSource::Local(dest) => {
                // make it absolute to not confuse ./upgrade.nix
                (match std::fs::canonicalize(dest.path.clone()) {
                    Ok(abspath) => {
                        // Check whether we actually have something like a lorri repository
                        let release_nix = abspath.join("release.nix");
                        if release_nix.exists() {
                            Ok(UpgradeSource::Local(abspath))
                        } else {
                            Err(UpgradeSourceError::ReleaseNixDoesntExist(release_nix))
                        }
                    }
                    Err(err) => Err(match err.kind() {
                        std::io::ErrorKind::NotFound => {
                            UpgradeSourceError::LocalPathNotFound(dest.path)
                        }
                        _ => UpgradeSourceError::CantCanonicalizeLocalPath(err),
                    }),
                })?
            }
        })
    }
}

/// nix-env upgrade Lorri in the default profile.
pub fn main(upgrade_target: cli::UpgradeTo, cas: &ContentAddressable) -> OpResult {
    /*
    1. nix-instantiate the expression
    2. get all the changelog entries from <currentnumber> to <maxnumber>
    3. nix-build the expression's package attribute
    4. nix-env -i the package
     */
    let upgrade_expr = cas
        .file_from_string(include_str!("./upgrade.nix"))
        .expect("could not write to CAS");

    let expr = {
        let src = match UpgradeSource::from_cli_argument(upgrade_target) {
            Ok(src) => Ok(src),
            Err(UpgradeSourceError::LocalPathNotFound(p)) => Err(ExitError::user_error(format!(
                "Cannot upgrade to local repository {}: path not found",
                p.display()
            ))),
            Err(UpgradeSourceError::CantCanonicalizeLocalPath(err)) => Err(ExitError::user_error(
                format!("Problem accessing local repository:\n{:?}", err),
            )),
            Err(UpgradeSourceError::ReleaseNixDoesntExist(p)) => {
                Err(ExitError::user_error(format!(
                    "{} does not exist, are you sure this is a lorri repository?",
                    p.display()
                )))
            }
        }?;

        match src {
            UpgradeSource::Branch(ref b) => println!("Upgrading from branch: {}", b),
            UpgradeSource::Local(ref p) => println!("Upgrading from local path: {}", p.display()),
        }

        let mut expr = nix::CallOpts::file(&upgrade_expr);

        match src {
            UpgradeSource::Branch(b) => {
                expr.argstr("type", "branch");
                expr.argstr("branch", &b);
            }
            UpgradeSource::Local(p) => {
                expr.argstr("type", "local");
                expr.argstr(
                    "path",
                    p.to_str()
                        // TODO: this is unnecessary, argstr() should take an OsStr()
                        .expect("Requested Lorri source directory not UTF-8 clean"),
                );
            }
        }
        // ugly hack to prevent expr from being mutable outside,
        // since I can't sort out how to chain argstr and still
        // keep a reference
        expr
    };

    let changelog: changelog::Log = expr.clone().attribute("changelog").value().unwrap();

    println!("Changelog when upgrading from {}:", VERSION_BUILD_REV);
    for entry in changelog.entries {
        if VERSION_BUILD_REV < entry.version {
            println!();
            println!("{}:", entry.version);
            for line in entry.changes.lines() {
                println!("    {}", line);
            }
        }
    }

    println!("Building ...");
    match expr.clone().attribute("package").path() {
        Ok((build_result, gc_root)) => {
            let status = Command::new("nix-env")
                .arg("--install")
                .arg(build_result.as_path())
                .status()
                // TODO: check existence of commands at the beginning
                .expect("Error: failed to execute nix-env --install");
            // we can drop the temporary gc root
            drop(gc_root);

            if status.success() {
                info!("upgrade successful");
                ok()
            } else {
                Err(ExitError::expected_error(format!(
                    "\nError: nix-env command was not successful!\n{:#?}",
                    status
                )))
            }
        }
        // our update expression is broken, crash
        Err(e) => panic!("Failed to build the update! {:#?}", e),
    }
}
