let
  srcDef = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${srcDef.rev}.tar.gz";
    sha256 = srcDef.sha256;
  };
  # The version of nixpkgs-fmt in release-19.09 [1] does not support --check, which
  # we need for CI. Hence this overlay.
  # [1] https://github.com/NixOS/nixpkgs/blob/release-19.09/pkgs/tools/nix/nixpkgs-fmt/default.nix
  nixpkgs-fmt-overlay = self: super: {
    nixpkgs-fmt = self.callPackage ./nixpkgs-fmt.nix {};
  };
in
import nixpkgs { overlays = [ nixpkgs-fmt-overlay ]; }
