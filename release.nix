{
  package = import ./default.nix {};

  changelog = {
    # Find the current version number with `git log --pretty=%h | wc -l`
    entries = [
      {
        version = 676;
        changes = ''
          Make `lorri daemon` exit with exit code 0 instead of 130/143 on
          SIGINT or SIGTERM.
        '';
      }
      {
        version = 655;
        changes = ''
          Add `lorri self-upgrade branch` sub-subcommand.
          This enables us to point users to a branch name,
          in order to test out fixes from repository branches.
        '';
      }
      {
        version = 630;
        changes = ''
          Make the `lorri internal stream-events` Varlink events public, with sum-style types.
        '';
      }
      {
        version = 626;
        changes = ''
          Added manpage for lorri(1).
        '';
      }
      {
        version = 581;
        changes = ''
          Fix `lorri shell` for zsh. ZDOTDIR is loaded correctly.
        '';
      }
      {
        version = 572;
        changes = ''
          `lorri daemon` got a `--extra-nix-options` flag to pass further options
          to nix as a JSON object, or at least a subset.
          `builders` and `substituters` is supported for now.
        '';
      }
      {
        version = 568;
        changes = ''
          Added the `$IN_LORRI_SHELL` environment variable to allow
          differentiation between `nix-shell` and `lorri shell`. The variable is
          set to the path of the currently-evaluated shell file.
        '';
      }
      {
        version = 534;
        changes = ''
          Rename `lorri internal` commands for consistency:
            - `start_user_shell` -> `start-user-shell`
            - `stream_events` -> `stream-events`
        '';
      }
      {
        version = 518;
        changes = ''
          Internal subcommands is now visible for all users inside the internal
          subcommand. Example `lorri internal stream_events` instead of `lorri internal__stream_events`.
        '';
      }
      {
        version = 517;
        changes = ''
          - Fix issue with spaces in PATH entries
        '';
      }
      {
        version = 510;
        changes = ''
          - The shell.nix template used by `lorri init` was changed to take
            `pkgs` as an argument with import of `<nixpkgs>` used as the
            default value.
        '';
      }
      {
        version = 476;
        changes = ''
          Introduces internal subcommand `lorri internal__stream_events`

          The subcommand emits a stream of JSON objects representing build
          events, suitable for use in `jq | xargs` style scripts. Useful, for
          instance, to feed libnotify or to decorate a shell prompt.
        '';
      }
      {
        version = 467;
        changes = ''
          - Rename internal subcommand `lorri ping_` to `lorri internal__ping`
          - Rename internal subcommand `lorri start_user_shell_` to
            `lorri internal__start_user_shell`
        '';
      }
      {
        version = 450;
        changes = ''
          - Re-introduce `lorri shell`, which builds a project environment and
            launches a shell in it with no direnv setup required.
        '';
      }
      {
        version = 309;
        changes = ''
          - The deprecated `lorri shell` command was removed.
          - Fix problem with non-UTF8 build output, arbitrary bytes are now fine.
          - Add `--shell-file` option to `info`, `watch` and `direnv`.

          - `daemon`:
            - Panic when any thread panics.
              Before the daemon would just hang doing nothing.

          - `direnv`:
            - Print info messages when daemon is not running
              and/or project has not yet been evaluated.
            - Take `PWD`, `OLDPWD` and `SHELL` from user environment
              instead of shell file context.
            - Set `IN_NIX_SHELL` to `impure`.
              - Fixes SSL certificates being set to bogus path.

          - `watch`:
            - Add `--once` option to exit after one build.

          - Watcher logic:
            - Emulate Nix’s `default.nix` behaviour instead of watching
              the parent directory recursively.

          - Build logic:
            - Split `nix-instantiate` and `nix-build`, to provide
              fine-grained status events.
        '';
      }
      {
        version = 223;
        changes = ''
          - Running lorri on a project where the nix-shell dependencies
            are already cached (e.g. by running `nix-shell` directly before)
            is a completely local operation now (no binary cache is queried).
          - `lorri build` was a no-op, so it was removed
        '';
      }
      {
        version = 171;
        changes = ''
          gc_root dirs move from `~/.cache/lorri` to `~/.cache/lorri/gc_roots`.
          You can delete every file in `~/.cache/lorri`.
        '';
      }
      {
        version = 132;
        changes = ''
          Version #130 claimed to add Go support through GOPATH and
          the appended environment variables, however this wasn't
          true.

          This version does, actually, do that.

          We also fixed a bug where appended environment variables
          would include a leading delimiter even if it wasn't
          previously set.
        '';
      }
      {
        version = 130;
        changes = ''
          `lorri watch` now supports executing shellHooks.

          - shellHooks run inside `lorri watch`, and not in `direnv`

            This means they will execute only once, while inside the
            build sandbox.

            shellHooks are not to be used for starting services or
            printing text to the CLI, as these actions will not
            execute when the shell is entered.

          - Environment variables which are appended to the
            environment with Nixpkgs'
            addToSearchPathWithCustomDelimiter function will
            automatically be appended to the user's environment when
            entering the lorri shell.

            Notably, this means Go support.

            Many functions in Nixpkgs use
            addtoSearchPathWithCustomDelimiter, including:

             - addToSearchPath
             - addPythonPath
             - R libraries

            among others.

            Overall, this should allow a much more "nix-shell"-like
            experience.
        '';
      }
      {
        version = 129;
        changes = ''
          `lorri watch` now supports Vim's method of writing to files.

          Previously, the watch behavior would support a maximum of
          three reloads (#66).
        '';
      }
      {
        version = 59;
        changes = ''
          New: self-upgrade command.
        '';
      }
    ];
  };
}
