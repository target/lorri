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


  # lightweight sandbox; execute any command in an unshared
  # namespace that only has access to /nix and the specified
  # directories from `extraMounts`.
  sandbox = { extraMounts ? [] }:
    let
      pathsToMount = [
        "/nix"
        "/dev" "/proc" "/sys"
      ] ++ extraMounts;
      # chain execlines and exit immediately if one fails
      all = builtins.concatMap (c: [ "if" c ]);
      mount = "${pkgs.utillinux}/bin/mount";
      # this is the directory the sandbox runs under (in a separate mount namespace)
      newroot = pkgs.runCommand "sandbox-root" {} ''mkdir "$out"'';
      # this runs in a separate namespace, sets up a chroot root
      # and then chroots into the new root.
      sandbox = writeExecline "sandbox" {} (builtins.concatLists [
        # first, unshare the mount namespace and make us root
        # -> requires user namespaces!
        [ "${pkgs.utillinux}/bin/unshare" "--mount" "--map-root-user" ]
        (all
          # mount a temporary file system which we can chroot to;
          # we can use the fixed path newroot here, because the resulting
          # tmpfs cannot be seen from the outside world (we are in an unshared
          # mount )
          ([ [ mount "-t" "tmpfs" "container_root" newroot ] ]
          # now mount the file system parts we need into the chroot
          ++ builtins.concatMap
               (rootPath: [
                 [ "${pkgs.coreutils}/bin/mkdir" "-p" "${newroot}${rootPath}" ]
                 [ mount "--rbind" rootPath "${newroot}${rootPath}" ]
               ])
               pathsToMount))
        # finally, chroot into our new root directory
        [ "${pkgs.coreutils}/bin/chroot" newroot "$@" ]
      ]);
    in sandbox;


  # Generate script to run `executable` inside of a lightweight sandbox
  # within a tmpfs root filesystem (that is deleted after execution).
  # On Darwin the sandboxing does not work, so we just run in a tempdir.
  #
  # This is intended to test commands which change files in the
  # source directory (LORRI_ROOT). Make them deterministic.
  runInSourceSandboxed = { passEnv ? [] }: executable:
    let
      commonSetup = specificSetup: pkgs.writeShellScript "${executable.name}-setup" ''
        set -euo pipefail

        ${specificSetup}

        # copy the lorri repo to the temporary sandbox work directory
        ${pkgs.coreutils}/bin/cp -r "${LORRI_ROOT}" "$WORK_DIR"

        cd "$WORK_DIR"

        # clean env and run the shell script with extra arguments
        ${runInEmptyEnv passEnv} \
          ${executable} "$@"
      '';

      # in a non-sandbox we put everything in a tmpdir
      tmpdirSetup = ''
        WORK_DIR=$(mktemp -d)
        cleanup () {
          rm -rf "$WORK_DIR"
        }
        trap cleanup EXIT
      '';

      # in the sandbox we just set a fixed WORK_DIR
      sandboxSetup = ''
        export HOME=/work/sandbox-home
        ${pkgs.coreutils}/bin/mkdir -p "$HOME"

        WORK_DIR=/work/lorri
      '';

    in
      if pkgs.stdenv.isDarwin then commonSetup tmpdirSetup
      else
        writeExecline "${executable.name}-sandboxed" {} [
          (sandbox {
            # The path in "$LORRI_ROOT" is mounted into the sandbox
            # read-write before running `setupScript`, at exactly the same
            # absolute path as outside of the sandbox.
            extraMounts = [ LORRI_ROOT ];
          })
          (commonSetup sandboxSetup)
        ];

in { inherit runInSourceSandboxed runInEmptyEnv sandbox; }
