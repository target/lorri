# lorri


Usage: `lorri [general options] <command> [...args]`

Lorri is a build tool based on Nix, specialized to build small projects and monorepos.

Usable both on the developer’s machine and on CI.


## Tutorial

You can find the **lorri tutorial** [in the `./example`
directory](./example).


## Install

```
$ git clone https://github.com/target/lorri.git
$ cd lorri
$ nix-env -i -f .
```

## Upgrading

Upgrading lorri is easy with the `lorri self-upgrade` command.

By default, the upgrade command will upgrade from the
`rolling-release` branch.

Other upgrade options are available, including upgrading from a
local clone. See `lorri self-upgrade --help` for more details.

## Setup

Lorri works on any `shell.nix` automatically.

Add `.lorri` to your projects version-control ignore list, like
`.gitignore`.

See [the example](./example/) for a tutorial!

## Commands

### Direnv

Lorri has full support for Direnv. It is a bit tedious to setup, but
is much nicer than the `lorri shell` option.

1. Install direnv v2.19.2 or later
2. Create a `.envrc` with contents like this:

```
eval "$(lorri direnv)"
```

3. Open a terminal, enter the project directory, and run
`lorri watch`. Leave this terminal open.
4. Use direnv like normal.

The `lorri watch` process will continue monitoring and evaluating
the Nix expressions, and direnv will automatically reload the
environment as it changes.

### Project Shell

Note: `lorri shell` still functions, but the `direnv` support is much
nicer.

    lorri shell

or if you're working inside a `nix-shell` with `cargo`:

    cargo run -- shell

for more logs:

    RUST_LOG=lorri=debug RUST_BACKTRACE=1 cargo run -- shell

Open a project shell for your Lorri project.

## Project Root

The root of your project the directory containing the `shell.nix`.
Lorri will not look in parent directories for a `shell.nix`.

---

# Evaluator + watch design

The evaluator should eagerly reevaluate the Nix expressions as soon as
anything material to their output changes. This takes place in a few
stages.

## Initial evaluation

`builder::run()` instantiates (and builds) the Nix expression with
`nix-build -vv`. The evalutor prints each imported Nix file, and
each copied source file. `builder::run()` parses the log and noteseach
of these paths out as an "input" path.

Each input path is the absolute path which Nix examined.

Each "input" path is then passed to `PathReduction` which examines each
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

Each identified path is watched for changes with inotify. If the
watched path is a directory, all of its sub-directories are also
watched for changes.

Each new batch of change notifications triggers a fresh evaluation.
Newly discovered paths are added to the inotify watch list.

## Rooting

Each evaluation, lorry creates an indirect GC root for each .drv in
`./.lorri/gc_roots/`.

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

_(Nix as observed by LORRI on 2015-07-13)_
