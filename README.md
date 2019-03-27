# lorri

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

lorri is a `nix-shell` replacement for project development. lorri is
based around fast direnv integration for robust CLI and editor
integration.

The project is about experimenting with and improving the developer's
experience with Nix. A particular focus is managing your project's
external dependencies, editor integration, and quick feedback.

Lorri supports Linux and macOS.

## Tutorial

You can find the **lorri tutorial** [in the `./example`
directory](./example).


## Install

### Install direnv

You will need [direnv v2.19.2 or later][direnv-2-19-2].

On NixOS, we have a simple service for installing and enabling the
needed direnv version at [./direnv/nixos.nix](./direnv/nixos.nix).
Download this file and add `imports = [ ./direnv.nix ];` to your
system's `configuration.nix`.

For Nix on Linux or macOS, you can install the needed version of
direnv with:

```
$ curl -o direnv.nix https://github.com/target/lorri/raw/master/direnv/nix.nix
$ nix-env -if ./direnv.nix
```

then enable it according to [direnv's setup instructions][direnv-setup].

### Installing lorri

Install with nix-env:

```
$ nix-env -if https://github.com/target/lorri/tarball/rolling-release
```

## Usage

Create a file named `.envrc` in your project's root with the contents:

```
eval "$(lorri direnv)"
```

Then, run `lorri watch`. The first time you run `lorri watch` on a
project, wait for it to print `Completed` before continuing. Leave
this terminal open.

In a new terminal:

1. enter the project directory
2. run `direnv allow`
3. watch as direnv loads the environment

The `lorri watch` process will continue monitoring and evaluating
the Nix expressions, and direnv will automatically reload the
environment as it changes. If you close `lorri watch`, direnv will
still load the cached environment when you enter the directory,
but the environment will not reload.

## Debugging

Set these environment variables when debugging:

```
RUST_LOG=lorri=debug RUST_BACKTRACE=1 lorri watch
```

---

## Upgrading

Upgrading lorri is easy with the `lorri self-upgrade` command.

By default, the upgrade command will upgrade from the
`rolling-release` branch.

Other upgrade options are available, including upgrading from a
local clone. See `lorri self-upgrade --help` for more details.


# Evaluator + watch design

The evaluator should eagerly reevaluate the Nix expressions as soon as
anything material to their output changes. This takes place in a few
stages.

## Initial evaluation

`builder::run()` instantiates (and builds) the Nix expression with
`nix-build -vv`. The evaluator prints each imported Nix file, and
each copied source file. `builder::run()` parses the log and notes each
of these paths out as an "input" path.

Each input path is the absolute path which Nix examined.

Each input path is then passed to `PathReduction` which examines each
path referenced, and reduces it to a minimum set of paths with the
following rules:

1. Discard any store paths which isn't a symlink to outside
   the store: they are immutable.
2. Replace any store path which is a symlink to outside the store to
   the destination of the symlink.
3. Replace a reference to a Nix Channel with the updateable symlink
   root of the channel. Concretely, replace the path
   `/nix/var/nix/profiles/per-user/root/channels/nixos/default.nix` with
   `/nix/var/nix/profiles/per-user/root/` to watch for the channels
   symlink to change.

Initial testing collapses over 2,000 paths to just five.

## Loop

Each identified path is watched for changes with inotify (Linux) or
fsevent (macOS). If the watched path is a directory, all of its
sub-directories are also watched for changes.

Each new batch of change notifications triggers a fresh evaluation.
Newly discovered paths are added to the watch list.

## Garbage Collection Roots

lorri creates an indirect garbage collection root for each .drv in
`$XDG_CACHE_HOME/lorri` (`~/.cache/lorri/` by default) each time it
evaluates your project.


---

###### ASCII Art

    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    #################( )############################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################
    ################################################################

_([Nix as observed by LORRI on 2015-07-13](https://www.nasa.gov/newhorizons/lorri-gallery))_

[direnv-2-19-2]: https://github.com/direnv/direnv/releases/tag/v2.19.2
[direnv-setup]: https://direnv.net/index.html#setup
