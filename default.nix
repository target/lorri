{ pkgs ? import ./nix/nixpkgs.nix
, src ? pkgs.nix-gitignore.gitignoreSource [ ".git/" ] ./.
}:
(
  (
    pkgs.callPackage ./Cargo.nix {
      cratesIO = pkgs.callPackage ./nix/carnix/crates-io.nix {};
    }
  ).lorri {}
).override {
  crateOverrides = pkgs.defaultCrateOverrides // {
    lorri = attrs: {
      name = "lorri";
      # This is implicitely set by `builtins.fetchGit`
      # (which we use in `src/ops/upgrade/upgrade.nix`).
      # So if a user upgrades from a branch of the repository,
      # it will return a revCount. Default to `1` for e.g.
      # `self-upgrade local`.
      BUILD_REV_COUNT = src.revCount or 1;
      RUN_TIME_CLOSURE = pkgs.callPackage ./nix/runtime.nix {};
      NIX_PATH = "nixpkgs=${./nix/bogus-nixpkgs}";

      # required by human-panic, because carnix doesn’t
      # set the cargo environment variables correctly.
      # see https://doc.rust-lang.org/cargo/reference/environment-variables.html
      homepage = "https://github.com/target/lorri";

      preConfigure = ''
        . ${./nix/pre-check.sh}

        # Do an immediate, light-weight test to ensure logged-evaluation
        # is valid, prior to doing expensive compilations.
        nix-build --show-trace ./src/logged-evaluation.nix \
          --arg shellSrc ./tests/integration/basic/shell.nix \
          --arg runtimeClosure "$RUN_TIME_CLOSURE" \
          --no-out-link
      '';

      buildInputs = [ pkgs.nix pkgs.direnv pkgs.which pkgs.rustPackages.rustfmt ] ++ pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
        pkgs.darwin.Security
        pkgs.darwin.apple_sdk.frameworks.CoreServices
      ];
    };
  };
}
