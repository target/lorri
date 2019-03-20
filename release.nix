{ src }:
{
  package = import ./default.nix { inherit src; };

  changelog = {
    # Find the current version number with `git log --prety=%h | wc -l`
    entries = [
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
