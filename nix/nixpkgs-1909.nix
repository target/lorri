let
  srcDef = builtins.fromJSON (builtins.readFile ./nixpkgs-1909.json);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${srcDef.rev}.tar.gz";
    sha256 = srcDef.sha256;
  };
in
import nixpkgs {}
