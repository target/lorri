{
  pkgs ? import ./nix/nixpkgs.nix { },
  src ? pkgs.nix-gitignore.gitignoreSource [".git/"] ./.
}:
((pkgs.callPackage ./Cargo.nix {
  cratesIO = pkgs.callPackage ./crates-io.nix {};
}).lorri {}).override {
  crateOverrides = pkgs.defaultCrateOverrides // {
    lorri = attrs: {
      BUILD_REV_COUNT = src.revCount or 1;
      RUN_TIME_CLOSURE = pkgs.callPackage ./nix/runtime.nix {};
      NIX_PATH = "nixpkgs=${./nix/bogus-nixpkgs}";

      preConfigure = ''
        . ${./nix/pre-check.sh}

        # Do an immediate, light-weight test to ensure logged-evaluation
        # is valid, prior to doing expensive compilations.
        nix-build --show-trace ./src/logged-evaluation.nix \
          --arg src ./tests/integration/basic/shell.nix \
          --arg runTimeClosure "$RUN_TIME_CLOSURE" \
          --no-out-link
      '';

      buildInputs = [ pkgs.nix pkgs.direnv pkgs.which ] ++
      pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
        pkgs.darwin.cf-private
        pkgs.darwin.Security
        pkgs.darwin.apple_sdk.frameworks.CoreServices
      ];
    };
  };
}
