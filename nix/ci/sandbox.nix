{ pkgs, LORRI_ROOT, writeExecline }:

let

  # remove everything but a few selected environment variables
  runInEmptyEnv = additionalVars:
    let
        baseVars = [ "USER" "HOME" "TERM" ];
        keepVars = baseVars ++ additionalVars;
        importas = pkgs.lib.concatMap (var: [ "importas" var var ]) keepVars;
        # we have to explicitely call export here, because PATH is probably empty
        export = pkgs.lib.concatMap (var: [ "${pkgs.execline}/bin/export" var ''''${${var}}'' ]) keepVars;
    in writeExecline "empty-env" {}
         (importas ++ [ "emptyenv" ] ++ export ++ [ "${pkgs.execline}/bin/exec" "$@" ]);

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

        # clean env and run the shell script with extra arguments
        ${runInEmptyEnv passEnv} \
          ${executable} "$@"
      '';

      sandboxSetup = ''
        export HOME=/work/sandbox-home
        ${pkgs.coreutils}/bin/mkdir -p "$HOME"

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

in { inherit runInSourceSandboxed runInEmptyEnv; }
