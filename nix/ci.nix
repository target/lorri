{ pkgs, LORRI_ROOT, rust }:
let
  # Pipe a value through a few functions, left to right.
  # pipe 2 [ (v: v +1) (v: v *2) ] == 6
  # TODO upstream into nixpkgs
  pipe = val: fns: let revApply = x: f: f x; in builtins.foldl' revApply val fns;

  inherit (import ./execline.nix { inherit pkgs pipe; })
    writeExecline writeExeclineBin;

  # command to run mdsh inside of a lightweight sandbox
  # with a tmpfs root filesystem (that is deleted after execution).
  # You can run it like this, without having to worry about any dangerous
  # commands being executed on your files:
  # $ env lorri-mdsh-sandbox -i $(realpath ./README.md)
  mdsh-sandbox =
    let
      emptySetupScript = pkgs.writeShellScriptBin "lorri-mdsh-sandbox" "";
      setupScript = pkgs.writeShellScriptBin "lorri-mdsh-sandbox" ''
        set -e
        export HOME=/work/sandbox-home
        mkdir -p "$HOME"

        WORK_DIR=/work/lorri
        # copy the lorri repo to the temporary sandbox work directory
        cp -r "${LORRI_ROOT}" "$WORK_DIR"

        # required to run `nix-env` in mdsh
        mkdir /work/sandbox-home/.nix-defexpr

        # clean env and run mdsh with extra arguments
        env -i \
          USER="$USER" \
          HOME="$HOME" \
          PATH="$PATH" \
          NIX_PROFILE="$HOME/nix-profile" \
            ${pkgs.mdsh}/bin/mdsh \
              --work_dir "$WORK_DIR/$SUBDIR" \
              "$@"
      '';
    in
      # on Darwin there’s no way to sandbox, so the script should be a no-op
      if pkgs.stdenv.isDarwin then emptySetupScript

      else pkgs.buildSandbox setupScript {
        # the whole nix store is mounted in the sandbox,
        # to make nix builds possible
        fullNixStore = true;
        # The path in "$LORRI_ROOT" is magically mounted into the sandbox
        # read-write before running `setupScript`, at exactly the same
        # absolute path as outside of the sandbox.
        paths.required = [ LORRI_ROOT ];
      };

  # the CI tests we want to run
  tests = {
    cargo-fmt = {
      description = "cargo fmt was done";
      test = writeExecline "lint-cargo-fmt" {} [ "${rust}/bin/cargo" "fmt" "--" "--check" ];
    };
    cargo-test = {
      description = "run cargo test";
      test = writeExecline "cargo-test" {} [ "${rust}/bin/cargo" "test" ];
    };
    cargo-clippy = {
      description = "run cargo clippy";
      test = writeExecline "cargo-clippy" {} [
        "export" "RUSTFLAGS" "-D warnings"
        "${rust}/bin/cargo" "clippy"
      ];
    };
  };

in {
  inherit
    mdsh-sandbox tests;
}
