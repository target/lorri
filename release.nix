{ src }:
{
  package = import ./default.nix { inherit src; };

  changelog = {
    # Find the current version number with `git log --prety=%h | wc -l`
    entries = [
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
