{
  # Pull in tools & environment variables that are only
  # required for interactive development (i.e. not necessary
  # on CI). Only when this is enabled, Rust nightly is used.
  isDevelopmentShell ? true
, pkgs ? import ./nix/nixpkgs.nix
}:

let
  # Keep project-specific shell commands local
  HISTFILE = "${toString ./.}/.bash_history";

  # Lorri-specific

  # The root directory of this project
  LORRI_ROOT = toString ./.;
  # Needed by the lorri build.rs to determine its own version
  # for the development repository (non-release), we set it to 1
  BUILD_REV_COUNT = 1;
  # Needed by the lorri build.rs to access some tools used during
  # the build of lorri's environment derivations.
  RUN_TIME_CLOSURE = pkgs.callPackage ./nix/runtime.nix {};

  # Rust-specific

  # Enable printing backtraces for rust binaries
  RUST_BACKTRACE = 1;

  # Only in development shell

  # Needed for racer “jump to definition” editor support
  # In Emacs with `racer-mode`, you need to set
  # `racer-rust-src-path` to `nil` for it to pick
  # up the environment variable with `direnv`.
  RUST_SRC_PATH = "${pkgs.rustc.src}/lib/rustlib/src/rust/src/";
  # Set up a local directory to install binaries in
  CARGO_INSTALL_ROOT = "${LORRI_ROOT}/.cargo";

  buildInputs = [
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.git
    pkgs.direnv
    pkgs.shellcheck
    pkgs.nix-prefetch-git

    # To ensure we always have a compatible nix in our shells.
    # Travis doesn’t know `nix-env` otherwise.
    pkgs.nix
  ] ++ pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.Security
    pkgs.darwin.apple_sdk.frameworks.CoreServices
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
  ] ++ pkgs.stdenv.lib.optionals (!pkgs.stdenv.isDarwin) [
    # Cachix is broken on macOS [1] and clippy is not built by Hydra [2].
    # Building clippy and carnix on macOS in CI takes about 25 minutes, so we
    # don't run lints (which require clippy) on macOS.
    #
    # [1] https://github.com/cachix/cachix/issues/228#issuecomment-533634704
    # [2] https://github.com/NixOS/nixpkgs/issues/77358
    pkgs.rustPackages.clippy
    pkgs.carnix

    # These other tools are also used only for linting, and are thus not
    # required on macOS.
    pkgs.nixpkgs-fmt
  ];

  # we manually collect all build inputs,
  # because `mkShell` derivations cannot be built
  # and we want to cachix them.
  allBuildInputs = buildInputs;

in
pkgs.mkShell (
  {
    name = "lorri";
    buildInputs = buildInputs
    ++ pkgs.stdenv.lib.optionals isDevelopmentShell [ pkgs.rustracer ];

    inherit BUILD_REV_COUNT RUN_TIME_CLOSURE;

    inherit RUST_BACKTRACE;

    # Executed when entering `nix-shell`
    shellHook = ''
      # we can only output to stderr in the shellHook,
      # otherwise direnv `use nix` does not work.
      # see https://github.com/direnv/direnv/issues/427
      exec 3>&1 # store stdout (1) in fd 3
      exec 1>&2 # make stdout (1) an alias for stderr (2)

      alias ci="ci_check"

      # this is mirrored from .envrc to make available from nix-shell
      # pick up cargo plugins
      export PATH="$LORRI_ROOT/.cargo/bin:$PATH"
      # watch the output to add lorri once it's built
      export PATH="$LORRI_ROOT/target/debug:$PATH"

      function ci_lint() (
        cd "$LORRI_ROOT";
        source ./.travis_fold.sh

        set -x

        lorri_travis_fold fmt-nix ./nix/fmt.sh --check
        nix_fmt=$?

        lorri_travis_fold carnix-update ./nix/update-carnix.sh
        carnixupdate=$?

        lorri_travis_fold cargo-fmt \
          cargo fmt -- --check
        cargofmtexit=$?

        RUSTFLAGS='-D warnings' \
          lorri_travis_fold cargo-clippy cargo clippy
        cargoclippyexit=$?

        set +x
        echo "./nix/fmt.sh --check: $nix_fmt"
        echo "carnix update: $carnixupdates"
        echo "cargo fmt: $cargofmtexit"
        echo "cargo clippy: $cargoclippyexit"

        sum=$((nix_fmt + carnixupdate + cargofmtexit + cargoclippyexit))
        if [ "$sum" -gt 0 ]; then
          return 1
        fi
      )

      function ci_test() (
        cd "$LORRI_ROOT";
        source ./.travis_fold.sh

        set -x

        lorri_travis_fold script-tests ./script-tests/run-all.sh
        scripttests=$?

        lorri_travis_fold cargo-test cargo test
        cargotestexit=$?

        set +x
        echo "script tests: $scripttests"
        echo "cargo test: $cargotestexit"

        sum=$((scripttest + cargotestexit))
        if [ "$sum" -gt 0 ]; then
          return 1
        fi
      )

      function ci_check() (
        ci_lint
        lint=$?

        ci_test
        test=$?

        sum=$((lint + test))
        if [ "$sum" -gt 0 ]; then
          return 1
        fi
      )

      ${pkgs.lib.optionalString isDevelopmentShell ''
      echo "lorri" | ${pkgs.figlet}/bin/figlet | ${pkgs.lolcat}/bin/lolcat
      (
        format="  %-12s %s\n"
        printf "$format" alias executes
        printf "$format" ----- --------
        IFS=$'\n'
        for line in $(alias); do
          [[ $line =~ ^alias\ ([^=]+)=(\'.*\') ]]
          printf "$format" "''${BASH_REMATCH[1]}" "''${BASH_REMATCH[2]}"
        done
      )
    ''}

      # restore stdout and close 3
      exec 1>&3-
    '' + (
      if !pkgs.stdenv.isDarwin then "" else ''
        # Cargo wasn't able to find CF during a `cargo test` run on Darwin.
        export NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS"
      ''
    );

    passthru.allBuildInputs = allBuildInputs;

    preferLocalBuild = true;
    allowSubstitutes = false;
  }
  // (
    if isDevelopmentShell then {
      inherit RUST_SRC_PATH CARGO_INSTALL_ROOT HISTFILE;
    } else {}
  )
)
