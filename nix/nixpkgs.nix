let
  nixpkgsSrc = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  mozSrc = builtins.fromJSON (builtins.readFile ./mozilla.json);
  mozOverlay = import (
    builtins.fetchTarball {
      url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${mozSrc.rev}.tar.gz";
      inherit (mozSrc) sha256;
    }
  );
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsSrc.rev}.tar.gz";
    inherit (nixpkgsSrc) sha256;
  };
in
import nixpkgs { overlays = [ mozOverlay ]; }
