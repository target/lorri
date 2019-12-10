let
  nixpkgs-src = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  nixpkgs = import (
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs-src.rev}.tar.gz";
      sha256 = nixpkgs-src.sha256;
    }
  );

  mozilla-overlay-src = builtins.fromJSON (builtins.readFile ./nixpkgs-mozilla.json);
  mozilla-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${mozilla-overlay-src.rev}.tar.gz";
      sha256 = mozilla-overlay-src.sha256;
    }
  );

  rust-overlay = _self: _super: {
    rust-nightly = (nixpkgs { overlays = [ mozilla-overlay ]; }).rustChannelOf (import ./rust-nightly.nix);
  };
in
nixpkgs { overlays = [ rust-overlay ]; }
