# Maintaining lorri

## Cutting a release

TODO: https://github.com/target/lorri/issues/269

## Publishing a release on [nixpkgs][]

Currently (2020-01-30), lorri is available in the `nixos-unstable` and
`nixos-19.09` release channels, which correspond to the `master` and
`release-19.09` branches in the [nixpkgs][] repository, respectively.

The relevant directories and files in [nixpkgs][] are:
- [`pkgs/tools/misc/lorri`][nixpkgs-lorri-tool] declares the command line tool
- [`nixos/modules/services/development/lorri.nix`][nixpkgs-lorri-service]
  declares the systemd module
- [`nixos/tests/lorri`][nixpkgs-lorri-tests] declares the NixOS integration
  test suite

To update the lorri version in [nixpkgs][]:
1. **`nixos-unstable`**: update the lorri version in a PR against `master`, see
   for example [NixOS#77380](https://github.com/NixOS/nixpkgs/pull/77380).
2. **`nixos-19.09`**: _after_ the first PR has been merged into `master`,
   follow the [backporting procedure][nixpkgs-backporting]; see for example
   [NixOS#77432](https://github.com/NixOS/nixpkgs/pull/77432).

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates `nixpkgs.json` to the latest commit of the
`nixos-unstable` channel.

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

Run `./nix/update-carnix.sh` to update Cargo's dependency list.

[nixpkgs]: https://github.com/NixOS/nixpkgs/
[nixpkgs-backporting]: https://github.com/NixOS/nixpkgs/blob/d6a98987717b31e2d89b267608ea6c90bd5eea56/.github/CONTRIBUTING.md#backporting-changes
[nixpkgs-lorri-service]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/development/lorri.nix
[nixpkgs-lorri-tests]: https://github.com/NixOS/nixpkgs/tree/master/nixos/tests/lorri
[nixpkgs-lorri-tool]: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/misc/lorri
