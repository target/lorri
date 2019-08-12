# Maintaining lorri

## Cutting a release

TODO

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates

* `nixpkgs` to the latest commit of the `nixos-unstable` channel.
* the rust nighly channel used for rust development tools (like the
  Rust Language Server).

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

The rust stable version (needed for `rust clippy`) should be manually
bumped in `shell.nix`, the `stableVersion` string in the
`rustChannels` definition.

<!-- TODO: should we switch to `nightly` for everything instead of using
`stable` just for cargo clippy? -->

Run `./nix/update-carnix.sh` to update Cargo's dependency list.
