{ pkgs, LORRI_ROOT }:

let
  # Generate script to run `executable` inside of a lightweight sandbox
  # within a tmpfs root filesystem (that is deleted after execution).
  # On Darwin the sandboxing does not work, so we just run in a tempdir.
  #
  # This is intended to test commands which change files in the
  # source directory (LORRI_ROOT). Make them deterministic.
  runInSourceSandboxed = { passEnv ? [] }: executable:
    let
      commonSetup = specificSetup: pkgs.writeShellScriptBin executable.name ''
        set -euo pipefail

        ${specificSetup}

        # copy the lorri repo to the temporary sandbox work directory
        cp -r "${LORRI_ROOT}" "$WORK_DIR"

        cd "$WORK_DIR"

        # takes the name of an environment variable and returns
        # an argument which can be passed to env(1) to pass the variable through
        passEnv() {
          printf '%s=%s' "$1" "''${!1}"
        }

        # clean env and run the shell script with extra arguments
        env -i \
          $(passEnv "USER") \
          $(passEnv "HOME") \
          $(passEnv "TERM") \
          ${pkgs.lib.concatMapStringsSep "\n" (env: ''$(passEnv "${env}") \'') passEnv} \
          ${executable} "$@"
      '';

      sandboxSetup = ''
        export HOME=/work/sandbox-home
        mkdir -p "$HOME"

        WORK_DIR=/work/lorri
      '';

      # on darwin we bugger out and just do everything in a temp dir
      darwinSetup = ''
        WORK_DIR=$(mktemp -d)
        cleanup () {
          rm -rf "$WORK_DIR"
        }
        trap cleanup EXIT
      '';

      # copy the binary `name` directly to a new $out
      onlyBin = name: drv: pkgs.runCommand drv.name {} ''
        cp ${drv}/bin/${name} $out
      '';

    in
      if pkgs.stdenv.isDarwin then commonSetup darwinSetup
      else onlyBin executable.name (pkgs.buildSandbox (commonSetup sandboxSetup) {
        # the whole nix store is mounted in the sandbox,
        # to make nix builds possible
        fullNixStore = true;
        # The path in "$LORRI_ROOT" is magically mounted into the sandbox
        # read-write before running `setupScript`, at exactly the same
        # absolute path as outside of the sandbox.
        paths.required = [ LORRI_ROOT ];
      });

in { inherit runInSourceSandboxed; }
