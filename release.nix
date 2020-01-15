{ src }:
{
  package = import ./default.nix { inherit src; };

  changelog = {
    # Find the current version number with `git log --pretty=%h | wc -l`
    entries = [
      {
        version = 429;
        changes = ''
          - Re-introduced `lorri shell` command.
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
