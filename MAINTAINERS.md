# Maintaining lorri

## Versioning scheme

Given a version number `MAJOR.MINOR`, increment the:
- `MAJOR` version when you make an incompatible change,
- `MINOR` version otherwise.

In order to apply this scheme to lorri, we need to define what "incompatible
change" means for lorri, a command line tool.

Let's clarify some terminology. lorri is a command line tool with multiple
**subcommands**. Those subcommands are either _external_ or _internal_.
Internal subcommands' names end in an underscore. There are _mandatory_ and
_optional_ **command line options**, which can be attached to the top-level
command or to subcommands.

Subcommands fall into two categories based on the intended consumer of their
outputs: their **outputs** may be for _human consumption_ or
_machine-readable_.

### When to make a major release

Increment the `MAJOR` version if since the last released version,
- for any _top-level_ command line option:
  - the command line option was removed or renamed, or
  - the command line option changed from being optional to being mandatory, or
- for any _external_ subcommand:
  - the subcommand was removed or renamed, or
  - a command line option for the subcommand was removed or renamed, or
  - a previously optional command line option for the subcommand was made
    mandatory, or
  - the subcommand has machine-readable output and the output format changed,
    or
- it is conceivable that a project that could previously be built successfully
  now fails to build with lorri, unless the previous behaviour is considered a
  bug.

In any other case, increment the `MINOR` version.

A change to an _internal_ subcommand is not considered an incompatible change
and thus does not in itself necessitate a major release.

Since lorri is exclusively built with Nix and its runtime dependencies are
captured in its runtime closure, changing a build-time or runtime dependency
does not in itself necessitate a major release.

## Cutting a release

TODO: https://github.com/target/lorri/issues/269

## Updating dependencies

Run `./nix/update-dependencies.sh` from the root directory of this
repository. This updates `nixpkgs.json` to the latest commit of the
`nixos-unstable` channel.

Afterwards, don’t forget to run `nix-shell` and `nix-build` to test
whether everything still builds.

Run `./nix/update-carnix.sh` to update Cargo's dependency list.
