# lorri

https://github.com/target/lorri

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

lorri is a `nix-shell` replacement for project development. lorri is
based around fast direnv integration for robust CLI and editor
integration.

:point_right: **[Check out our blog post][lorri-blog-post] to see how lorri
improves on the `nix-shell` experience during everyday development as well as
in common scenarios like channel updates and Nix garbage collection.**

The project is about experimenting with and improving the developer's
experience with Nix. A particular focus is managing your project's
external dependencies, editor integration, and quick feedback.

lorri supports Linux and macOS.

## Demo

This screencast shows lorri and direnv working together to reload the
development environment as `shell.nix` is updated:

<p align="center">
  <a href="https://www.tweag.io/posts/2019-03-28-introducing-lorri.html">
    <img width="600" src="./assets/2019-04-01-lorri-demo.gif?raw=true" alt="lorri screencast" />
  </a>
</p>

## Setup on NixOS or with `home-manager` on Linux

If you are using [NixOS][nixos] or [`home-manager`][home-manager] on Linux and
a Nixpkgs channel at least as recent as `nixos-19.09`, you can get started with
lorri as follows. Otherwise see the next section, [Setup on other
platforms](#setup-on-other-platforms).

1. **Enable the daemon service.** Set `services.lorri.enable = true;` in your
   NixOS [`configuration.nix`][nixos-service] or your home-manager
   [`home.nix`][home-manager-service].

   This will automatically install both the `lorri` command and `direnv`
   (both required for the next steps).

2. **Install direnv.** Add `pkgs.direnv` to `environment.systemPackages` in
   your NixOS `configuration.nix` or to `home.packages` in your home-manager
   `home.nix`.

3. **Set up the direnv hook for your shell.** See [this section][direnv-hook]
   of the direnv documentation.

4. **Activate the lorri integration.** Run `lorri init` in your project
   directory to create a `shell.nix` and [`.envrc`][direnv-usage] file. This
   will not overwrite existing files.

   In your shell, you will now see the following message from direnv:

   ```console
   direnv: error .envrc is blocked. Run `direnv allow` to approve its content.
   ```

   Activate the integration by running [`direnv allow`][direnv-usage].

From this point on, lorri monitors your `shell.nix` and its dependencies and
triggers builds as required. Whenever a build succeeds, direnv automatically
reloads your environment.

See [Usage](#usage) for more details.

## Setup on other platforms

If you are running Nix on a Linux distribution other than NixOS or on macOS,
the following instructions will help you get started with lorri.

1. **Install lorri.** If you are using a Nixpkgs channel at least as recent
   as `nixos-19.09`, you can install lorri using `nix-env -i lorri`.

   Otherwise, install lorri from the repository as follows:

   ```console
   $ nix-env -if https://github.com/target/lorri/archive/rolling-release.tar.gz
   ```

2. **Start the daemon.** For testing, you can start the daemon in a separate
   terminal by running `lorri daemon`.

   See [`contrib/daemon.md`](contrib/daemon.md) for ways to start the daemon
   automatically in the background.

3. **Install direnv v2.19.2 or later.** If you are using a Nixpkgs channel at
   least as recent as `nixos-19.03`, you can install a compatible version of
   direnv using `nix-env -i direnv`.

   Otherwise, you can install direnv from source as follows:

   ```console
   $ nix-env -if https://github.com/direnv/direnv/archive/master.tar.gz
   ```

4. **Set up the direnv hook for your shell.** See [this section][direnv-hook]
   of the direnv documentation.

5. **Activate the lorri integration.** Run `lorri init` in your project
   directory to create a `shell.nix` and [`.envrc`][direnv-usage] file. This
   will not overwrite existing files.

   In your shell, you will see the following message from direnv:

   ```console
   direnv: error .envrc is blocked. Run `direnv allow` to approve its content.
   ```

   Activate the integration by running [`direnv allow`][direnv-usage].

From this point on, lorri monitors your `shell.nix` and its dependencies and
triggers builds as required. Whenever a build succeeds, direnv automatically
reloads your environment.

See [Usage](#usage) for more details.

## Usage

Once the daemon is running and direnv is set up, the daemon process will
continue monitoring and evaluating the Nix expressions in your project's
`shell.nix`, and direnv will automatically reload the environment as it
changes.

direnv will continue to load the *cached environment* when the daemon is not
running. However, the daemon must be running for direnv to reload the
environment based on the current `shell.nix` and its dependencies.


## Editor integration

With the right setup, you can use lorri and direnv to customize your
development environment for each project.

If you use Emacs, our [`direnv-mode` tutorial](./contrib/emacs.md) is there to
help you get started.

This section needs to be fleshed out more
([#244](https://github.com/target/lorri/issues/244)).

---

## Support & Questions

Please use the [issue tracker](https://github.com/target/lorri/issues)
for any problems or bugs you encounter. We are on `#lorri` on
`freenode` ([Webchat][]), though we might not be responsive at all
times.

[Webchat]: https://kiwiirc.com/nextclient/#irc://irc.freenode.net:+6697/#lorri

## How To Help

All development on lorri happens on the Github repository, in the
open. You can propose a change in an issue, then create a pull request
after some discussion. Some issues are marked with the “good first
issue” label, those are a good place to start. Just remember to leave
a comment when you start working on something.

## Debugging

Set these environment variables when debugging:

```
RUST_LOG=lorri=debug RUST_BACKTRACE=1 lorri watch
```

### lorri reevaluates more than expected

lorri sometimes recursively watches a directory that the user did
not expect. This can happen for a number of reasons:

1. When using a local checkout instead of a channel for `nixpkgs`,
   lorri watches that directory recursively, and will trigger on
   any file change.
2. When specifying `src` via a path, (like the much-used `src = ./.;`)
   lorri watches that path recursively (see
   https://github.com/target/lorri/issues/6 for details).
   To get around this, use a `builtins.filterSource`-based function
   to filter `src`, e.g., use
   [`nix-gitignore`](https://github.com/NixOS/nixpkgs/blob/8c1f1b2324bb90f8e1ea33db3253eb30c330ed99/pkgs/build-support/nix-gitignore/default.nix):
   `src = pkgs.nix-gitignore.gitignoreSource [] ./.`, or one of the
   functions in
   [`nixpkgs/lib/sources.nix`](https://github.com/NixOS/nixpkgs/blob/8c1f1b2324bb90f8e1ea33db3253eb30c330ed99/lib/sources.nix)
3. When using a construct like `import ./.` to import a `default.nix`
   file, lorri watches the current directory recursively. To get
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

[contrib]: ./contrib
[direnv-hook]: https://direnv.net/docs/hook.html
[direnv-setup]: https://direnv.net/index.html#setup
[direnv-usage]: https://direnv.net/man/direnv.1.html#usage
[home-manager-service]: https://rycee.gitlab.io/home-manager/options.html#opt-services.lorri.enable
[home-manager]: https://rycee.gitlab.io/home-manager/
[lorri-blog-post]: https://www.tweag.io/posts/2019-03-28-introducing-lorri.html
[nixos-service]: https://nixos.org/nixos/options.html#services.lorri.enable
[nixos]: https://nixos.org/
