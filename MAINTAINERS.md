# Maintaining lorri

## Versioning scheme

The versioning scheme for lorri is `MAJOR.MINOR`, where `MAJOR` and `MINOR` are
non-negative integers without leading zeroes.

### Terminology

lorri is a command line tool with multiple **subcommands**. Those subcommands
are either _external_ or _internal_.  Internal subcommands' names start with
"internal\_\_". There are _mandatory_ and _optional_ **command line options**,
which can be attached to the top-level command or to subcommands.

Subcommands fall into two categories based on the intended consumer of their
outputs: their **outputs** may be for _human consumption_ or
_machine-readable_.

### Major or minor release?

**Basic rule:** increment the `MAJOR` version when it is conceivable that a
user is _forced to change how they interact_ with lorri.

For example: it's a major release if since the last released version,
- for any _top-level_ command line option:
  - the command line option was removed or renamed, or
  - the command line option changed from being optional to being mandatory, or
- for any _external_ subcommand:
  - the subcommand was removed or renamed, or
  - a command line option for the subcommand was removed or renamed, or
  - a previously optional command line option for the subcommand was made
    mandatory, or
  - the subcommand has machine-readable output and the output format changed
    (\*), or
- it is conceivable that a project that could previously be built successfully
  now fails to build with lorri, unless the previous behaviour is considered a
  bug.

In any other case, increment the `MINOR` version.

(\*) The exception to this rule is `lorri direnv`: it is an external command
with machine-readable output whose output may change between minor releases,
subject to the basic rule.

A change to an _internal_ subcommand is not considered an incompatible change
and thus does not in itself necessitate a major release. This includes internal
subcommands with machine-readable output.

Since lorri is exclusively built with Nix and its runtime dependencies are
captured in its runtime closure, changing a build-time or runtime dependency
does not in itself necessitate a major release.

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
