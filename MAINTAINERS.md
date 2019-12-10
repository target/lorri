# Maintaining lorri

## Cutting a release

TODO

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates

* `nixpkgs.json` to the latest commit of the `nixos-unstable` channel.
* `mozilla-nixpkgs.json` to the latest commit of the `mozilla-nixpkgs`
  repository. This is where we get Rust nightly from, which is required for
  Racer (development only).

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

Run `./nix/update-carnix.sh` to update Cargo's dependency list.
