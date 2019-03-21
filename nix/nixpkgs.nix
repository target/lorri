{ enableMozillaOverlay }:
let
  hostpkgs = import <nixpkgs> {};

  srcDef = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  nixpkgs = hostpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (srcDef) rev sha256;
  };


  # The Mozilla overlay exposes dynamic, constantly updating
  # rust binaries for development tooling. Not recommended
  # for production or CI builds, but is right now the best way
  # to get Clippy, since Clippy only compiles withm Nighly :(.
  #
  # Note it exposes the overlay at:
  #
  #    latest.rustChannels.stable.rust
  #
  # and has a corresponding attrset for nightly.
  mozilla-overlay =
    import
  (
    builtins.fetchTarball
    https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz
  );
in import nixpkgs {
  overlays = hostpkgs.lib.optional enableMozillaOverlay mozilla-overlay;
}
