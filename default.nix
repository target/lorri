{
  pkgs ? import ./nix/nixpkgs.nix { },
  src ? pkgs.nix-gitignore.gitignoreSource [".git/"] ./.
}:

let
  naersk = pkgs.callPackage (builtins.fetchTarball {
      url = "https://github.com/nmattia/naersk/archive/68c1c2b2b661913cdc5ecabea518dfdc4f449027.tar.gz";
      sha256 = "1ll310pl44kdbwfslzwvg2v7khf1y0xkg2j5wcfia4k7sj6bcl28";
  }) {};

  lorri =
    (naersk.buildPackage src {
      # every cargo package
      doDoc = false;
      name = "lorri";

    # only set for lorri
    }).overrideAttrs (old: {
      # required environment variables
      USER = "testuser";
      NIX_PATH = "nixpkgs=${./nix/bogus-nixpkgs}";
      # This is implicitely set by `builtins.fetchGit`
      # (which we use in `src/ops/upgrade/upgrade.nix`).
      # So if a user upgrades from a branch of the repository,
      # it will return a revCount. Default to `1` for e.g.
      # `self-upgrade local`.
      BUILD_REV_COUNT = src.revCount or 1;
      RUN_TIME_CLOSURE = pkgs.callPackage ./nix/runtime.nix {};

      nativeBuildInputs = old.nativeBuildInputs or []
        ++ [ pkgs.nix pkgs.direnv pkgs.which ];

      doCheck = true;

      buildInputs = pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
        pkgs.darwin.cf-private
        pkgs.darwin.Security
        pkgs.darwin.apple_sdk.frameworks.CoreServices
      ];

      preConfigure = ''
        . ${./nix/pre-check.sh}
        # Do an immediate, light-weight test to ensure logged-evaluation
        # is valid, prior to doing expensive compilations.
        nix-build --show-trace ./src/logged-evaluation.nix \
          --arg src ./tests/integration/basic/shell.nix \
          --arg runTimeClosure "$RUN_TIME_CLOSURE" \
          --no-out-link
      '';
    });

in lorri
