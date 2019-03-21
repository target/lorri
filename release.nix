{ src }:
{
  package = import ./default.nix { inherit src; };

  changelog = {
    entries = [
      {
        version = 59;
        changes = ''
          New: self-upgrade command.
        '';
      }
    ];
  };
}
