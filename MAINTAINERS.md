# Maintaining lorri

## Versioning scheme

The versioning scheme for lorri is `MAJOR.MINOR`, where `MAJOR` and `MINOR` are
non-negative integers without leading zeroes.

### Terminology

lorri is a command line tool with multiple **subcommands**. Those subcommands
are either _external_ or _internal_. _internal_ subcommands are now all grouped in `lorri internal`.
There are _mandatory_ and _optional_ **command line options**, which can be attached to the top-level command or to subcommands.

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

To cut a new release:
1. Determine if this is a [minor or major release](#versioning-scheme) and
   change the `version` field in `Cargo.toml` accordingly.
2. Build the project to update `Cargo.lock`, then run `nix/update-carnix.sh` to
   update `Cargo.nix`.
3. Create a PR with these changes and merge it. Note the hash of the merge
   commit.
4. Tag the merge commit using `git tag --sign <version> <merge commit hash>`.
   Here, `<version>` is used as the name of the tag. It should adhere to the
   `MAJOR.MINOR` format without prefix or suffix, for example `1.0` (and not
   `v1.0`).
5. Push the tag using `git push origin <version>`.

## Publishing a release on [nixpkgs][]

lorri is available in the `nixos-unstable` and the stable release channels
from 19.09, which correspond to the `master` and `release-<stable-release-date>`
(example: `release-20.03`) branches in the [nixpkgs][] repository, respectively.

The relevant directories and files in [nixpkgs][] are:
- [`pkgs/tools/misc/lorri`][nixpkgs-lorri-tool] declares the command line tool
- [`nixos/modules/services/development/lorri.nix`][nixpkgs-lorri-service]
  declares the systemd module
- [`nixos/tests/lorri`][nixpkgs-lorri-tests] declares the NixOS integration
  test suite

To update the lorri version in [nixpkgs][]:
1. **`nixos-unstable`**: update the lorri version in a PR against `master`, see
   for example [NixOS#77380][nixos-unstable-pr]. Make sure the NixOS
   integration tests pass. You can run them locally from the root directory of
   your nixpkgs clone with `nix-build . -A lorri.tests`. To run them on the
   NixOS infrastructure, post a comment on the PR with the following content:

   > @GrahamcOfBorg build lorri.tests

2. **latest `nixos` stable**: _after_ the first PR has been merged into `master`,
   if the new release is *not* a major version bump (aka a breaking change),
   follow the [backporting procedure][nixpkgs-backporting] to create a PR
   against `release-<latest-stable-release-date>` (e.g. `release-20.03`);
   see for example [NixOS#77432][nixos-stable-pr].
   Again, make sure the NixOS integration tests pass (see previous step).

   We only backport to latest stable, since NixOS has a policy of only
   supporting one stable version at a time.

   Q: why do we support an older `rusttc` then?

   A: Users often work with repositories that use an older nixpkgs pin,
   which might still be from before latest stable. If they add lorri
   as an overlay to their repository, it won’t work if we drop support
   for older rustc’s too early.

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates `nixpkgs.json` to the latest commit of the
`nixos-unstable` channel.

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

Run `./nix/update-carnix.sh` to update Cargo's dependency list.

[nixos-stable-pr]: https://github.com/NixOS/nixpkgs/pull/77432
[nixos-unstable-pr]: https://github.com/NixOS/nixpkgs/pull/77380
[nixpkgs]: https://github.com/NixOS/nixpkgs/
[nixpkgs-backporting]: https://github.com/NixOS/nixpkgs/blob/d6a98987717b31e2d89b267608ea6c90bd5eea56/.github/CONTRIBUTING.md#backporting-changes
[nixpkgs-lorri-service]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/development/lorri.nix
[nixpkgs-lorri-tests]: https://github.com/NixOS/nixpkgs/tree/master/nixos/tests/lorri
[nixpkgs-lorri-tool]: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/misc/lorri
