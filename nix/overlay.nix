{ pkgs }:
let
  srcDef = builtins.fromJSON (builtins.readFile pkgs);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${srcDef.rev}.tar.gz";
    sha256 = srcDef.sha256;
  };
in
import nixpkgs {
  overlays = [
    (
      final: super: {
        lorri = super.callPackage ../default.nix {};
      }
    )
  ];
}
