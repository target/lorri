<!-- This tutorial’s contents can be automatically checked with mdsh,
(https://github.com/zimbatm/mdsh).

Execute
```
$ lorri-mdsh-sandbox -i $(realpath ./README.md)
```
to update.
-->

# lorri

https://github.com/target/lorri

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

lorri is a `nix-shell` replacement for project development. lorri is
based around fast direnv integration for robust CLI and editor
integration.

The project is about experimenting with and improving the developer's
experience with Nix. A particular focus is managing your project's
external dependencies, editor integration, and quick feedback.

lorri supports Linux and macOS.

`$ lorri --help`
```
lorri 0.1.0
Graham Christensen <graham.christensen@target.com>
Lorri is a build tool based on Nix, specialized to build small projects and monorepos.

Usable both on the developer’s machine and on CI.

USAGE:
    lorri [FLAGS] <SUBCOMMAND>

FLAGS:
    -h, --help       
            Prints help information

    -V, --version    
            Prints version information

    -v, --verbose    
            Increase debug logging, can be passed multiple times. Supports up to -vvvv, and this setting is ignored if
            RUST_LOG is set.

SUBCOMMANDS:
    daemon          Start the multi-project daemon. Replaces `lorri watch`
    direnv          Emit shell script intended to be evaluated as part of direnv's .envrc, via: `eval "$(lorri
                    direnv)"`
    help            Prints this message or the help of the given subcommand(s)
    info            Show information about the current Lorri project
    init            Bootstrap files for a new setup
    ping_           (plumbing) Tell the lorri daemon to care about the current directory's project
    self-upgrade    Upgrade Lorri
    watch           Build `shell.nix` whenever an input file changes
```
## Tutorial

You can find the **lorri tutorial** [in the `./example`
directory](./example). After following this tutorial, you will have
a working setup of `lorri`, `direnv`, and working basic editor
integration into Emacs.

`$ ls ./example`
```
README.md
shell.nix
```
## Support & Questions

Please use the [issue tracker](https://github.com/target/lorri/issues)
for any problems or bugs you encounter. We are on `#lorri` on
`freenode` ([Webchat][]), though we might not be responsive at all
times.

[Webchat]: https://kiwiirc.com/nextclient/#irc://irc.freenode.net:+6697/#lorri

## How To Help

All development on lorri happens on the
[Github repository](https://github.com/target/lorri), in the open.
You can propose a change in an issue, then create a pull request
after some discussion. Some issues are marked with the “good first
issue” label, those are a good place to start. Just remember to leave
a comment when you start working on something.

## Install

### Install direnv

You will need [direnv v2.19.2 or later][direnv-2-19-2].

On NixOS, we have a simple service for installing and enabling the
needed direnv version at [./direnv/nixos.nix](./direnv/nixos.nix).
Download this file inside `/etc/nixos/` and add `imports = [ ./nixos.nix ];` to your
system's `configuration.nix`. Then run `nixos-rebuild switch` to install and enable it.

For Nix on Linux or macOS, you can install the needed version of
direnv with:

<!-- mdsh note: direnv setup tested in example/README.md -->
```
$ curl -o direnv.nix -L https://github.com/target/lorri/raw/master/direnv/nix.nix
$ nix-env -if ./direnv.nix
```

### Enable direnv

Enable direnv according to [its setup instructions][direnv-setup].

### Installing lorri

Install with nix-env:

<!-- mdsh note: lorri setup tested in example/README.md -->
```
$ git clone -b rolling-release https://github.com/target/lorri.git
$ cd lorri
$ nix-env -if .
```

## Usage

<!-- mdsh note: lorri direnv usage tested in example/README.md -->

Create a file named `.envrc` in your project's root with the contents:

```
# content of `.envrc` file:
eval "$(lorri direnv)"
```

Then, run `lorri daemon`. The first time you run `lorri daemon` on a
project, wait for it to print `Completed` before continuing. Leave
this terminal open.

In a new terminal:

1. enter the project directory
2. run `direnv allow`
3. watch as direnv loads the environment

The `lorri daemon` process will continue monitoring and evaluating
the Nix expressions, and direnv will automatically reload the
environment as it changes. If you close `lorri daemon`, direnv will
still load the cached environment when you enter the directory,
but the environment will not reload.

## Debugging

Set these environment variables when debugging:

```
RUST_LOG=lorri=debug RUST_BACKTRACE=1 lorri watch
```

### `lorri` reevaluates more than expected

`lorri` sometimes recursively watches a directory that the user did
not expect. This can happen for a number of reasons:

1. When using a local checkout instead of a channel for `nixpkgs`,
   `lorri` watches that directory recursively, and will trigger on
   any file change.
2. When specifying `src` via a path, (like the much-used `src = ./.;`)
   `lorri` watches that path recursively (see 
   https://github.com/target/lorri/issues/6 for details).
   To get around this, use a `builtins.filterSource`-based function
   to filter `src`, e.g., use
   [`nix-gitignore`](https://github.com/NixOS/nixpkgs/blob/8c1f1b2324bb90f8e1ea33db3253eb30c330ed99/pkgs/build-support/nix-gitignore/default.nix):
   `src = pkgs.nix-gitignore.gitignoreSource [] ./.`, or one of the
   functions in
   [`nixpkgs/lib/sources.nix`](https://github.com/NixOS/nixpkgs/blob/8c1f1b2324bb90f8e1ea33db3253eb30c330ed99/lib/sources.nix)
3. When using a construct like `import ./.` to import a `default.nix`
   file, `lorri` watches the current directory recursively. To get
   around it, use `import ./default.nix`.

---

## Upgrading

Upgrading lorri is easy with the `lorri self-upgrade` command.

By default, the upgrade command will upgrade from the
`rolling-release` branch.

Other upgrade options are available, including upgrading from a
local clone. See `lorri self-upgrade --help` for more details.


## Evaluator + watch design

The evaluator should eagerly reevaluate the Nix expressions as soon as
anything material to their output changes. This takes place in a few
stages.

### Initial evaluation

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

### Loop

Each identified path is watched for changes with inotify (Linux) or
fsevent (macOS). If the watched path is a directory, all of its
sub-directories are also watched for changes.

Each new batch of change notifications triggers a fresh evaluation.
Newly discovered paths are added to the watch list.

### Garbage Collection Roots

<!-- mdsh TODO: check -->

lorri creates an indirect garbage collection root for each .drv in
`$XDG_CACHE_HOME/lorri` (`~/.cache/lorri/` by default) each time it
evaluates your project.


### License & Copyright

Copyright 2019 Target
License: Apache 2.0 (see [`LICENSE` file](./LICENSE))

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
