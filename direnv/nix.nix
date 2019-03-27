let
  isOlderThan = wantedVersion: package:
    let
      parsedVersion = builtins.parseDrvName package.name;
      pkgVersion = package.version or (parsedVersion.version or 0);
    in (builtins.compareVersions wantedVersion pkgVersion) == 0;

  pkgs = import <nixpkgs> {
    overlays = [(self: super: {
      direnv = if isOlderThan "2.19.2" super.direnv
        then super.direnv.overrideAttrs (_: {
          name = "direnv-2.19.2";
          version = "2.19.2";
          src = self.fetchFromGitHub {
            owner = "direnv";
            repo = "direnv";
            rev = "v2.19.2";
            sha256 = "1iq9wmc63x1c7g1ixdhd6q3w1sx8xl8kf1bprxwq26n9zpd0g13g";
          };
        })
        else super.direnv;
    })];
  };
in pkgs.direnv
