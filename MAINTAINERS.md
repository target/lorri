# Maintaining lorri

## Cutting a release

TODO: https://github.com/target/lorri/issues/269

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates `nixpkgs.json` to the latest commit of the
`nixos-unstable` channel.

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

Run `./nix/update-carnix.sh` to update Cargo's dependency list.
