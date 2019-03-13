{ pkgs ? import ./nix/nixpkgs.nix { enableMozillaOverlay = true; } }:
pkgs.mkShell {
  name = "lorri";
  buildInputs = [
    # This rust comes from the Mozilla rust overlay so we can
    # get Clippy. Not suitable for production builds. See
    # ./nix/nixpkgs.nix for more details.
    pkgs.latest.rustChannels.stable.rust
    pkgs.bashInteractive
    pkgs.git
  ] ++
  pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.Security
    pkgs.darwin.apple_sdk.frameworks.CoreServices
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
  ];
  # Keep project-specific shell commands local
  HISTFILE = "${toString ./.}/.bash_history";
  RUST_BACKTRACE = 1;
  ROOT = toString ./.;
  BUILD_REV_COUNT = 1;
  shellHook = ''
    # we can only output to stderr in the shellHook,
    # otherwise direnv `use nix` does not work.
    # see https://github.com/direnv/direnv/issues/427
    exec 3>&1 # store stdout (1) in fd 3
    exec 1>&2 # make stdout (1) an alias for stderr (2)

    # this is needed so `lorri shell` runs the proper shell from
    # inside this project's nix-shell. If you run `lorri` within a
    # nix-shell, you don't need this.
    export SHELL="${pkgs.bashInteractive}/bin/bash";

    alias newlorri="(cd $ROOT; cargo run -- shell)"
    alias ci="ci_check"

    function ci_check() (
      cd "$ROOT";

      set -x

      cargo test
      cargotestexit=$?

      cargo fmt
      git diff --exit-code
      cargofmtexit=$?

      RUSTFLAGS='-D warnings' cargo clippy
      cargoclippyexit=$?

      set +x
      echo "cargo test: $cargotestexit"
      echo "cargo fmt: $cargofmtexit"
      echo "cargo clippy: $cargoclippyexit"

      sum=$((cargotestexit + cargofmtexit + cargoclippyexit))
      if [ "$sum" -gt 0 ]; then
        return 1
      fi
    )

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

    # restore stdout and close 3
    exec 1>&3-
  '' + (if !pkgs.stdenv.isDarwin then "" else ''
    # Cargo wasn't able to find CF during a `cargo test` run on Darwin.
    export NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS"
  '');
}
