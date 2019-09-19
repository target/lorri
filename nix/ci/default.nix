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

  # Write commands to script which aborts immediately if a command is not successful.
  # The status of the unsuccessful command is returned.
  allCommandsSucceed = name: commands: pipe commands [
    (pkgs.lib.concatMap (cmd: [ "if" [ cmd ] ]))
    (cmds: cmds ++ [ "true" ])
    (writeExecline name {})
  ];

  # Takes a `mode` string and produces a script,
  # which modifies PATH given by $1 and execs into the rest of argv.
  # `mode`s:
  #   "set": overwrite PATH, set it to $1
  #   "append": append the given $1 to PATH
  #   "prepend": prepend the given $1 to PATH
  pathAdd = mode:
    let exec = [ "exec" "$@" ];
        importPath = [ "importas" "PATH" "PATH" ];
        set = [ "export" "PATH" "$1" ] ++ exec;
        append = importPath ++ [ "export" "PATH" ''''${PATH}:''${1}'' ] ++ exec;
        prepend = importPath ++ [ "export" "PATH" ''''${1}:''${PATH}'' ] ++ exec;
    in writeExecline "PATH_${mode}" { readNArgs = 1; }
        (if    mode == "set"     then set
        else if mode == "append" then append
        else if mode == "prepend" then prepend
        else abort "don’t know mode ${mode}");

  # shellcheck file
  shellcheck = file: writeExecline "lint-shellcheck" {} [
    "cd" LORRI_ROOT
    # TODO: echo is coming from context, clean out PATH before running checks
    "foreground" [ "echo" "shellchecking ${file}" ]
    "${pkgs.shellcheck}/bin/shellcheck" "--shell" "bash" file
  ];

  # the CI tests we want to run
  # Tests should not depend on each other (or block if they do),
  # so that they can run in parallel.
  # If a test changes files in the repository, sandbox it.
  tests = {

    shellcheck =
      let files = [
        "nix/bogus-nixpkgs/builder.sh"
        "src/ops/direnv/envrc.bash"
      ];
      in {
        description = "shellcheck ${pkgs.lib.concatStringsSep " and " files}";
        test = allCommandsSucceed "lint-shellcheck-all" (map shellcheck files);
      };

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

  # Write a attrset which looks like
  # { "test description" = test-script-derviation }
  # to a script which can be read by `bats` (a simple testing framework).
  batsScript =
    let
      # first version of bats that has support for GNU parallel
      bats = pkgs.bats.overrideAttrs (_: { src = pkgs.fetchFromGitHub {
        owner = "bats-core";
        repo = "bats-core";
        rev = "8789f910812afbf6b87dd371ee5ae30592f1423f";
        sha256 = "1fkd3qqb1pi05szkzixl3n7qhwiji5xzbm2ghgbk3sb9wa1dyvf5";
      }; });
      # bats can only parallelize if it finds GNU parallel in its environment.
      batsParallel = writeExecline "bats" {} [
        (pathAdd "prepend") "${pkgs.parallel}/bin"
        "${bats}/bin/bats" "$@"
      ];
    in name: tests: pipe tests [
      (pkgs.lib.mapAttrsToList
        # a bats test looks like:
        # @test "name of test" {
        #   … test code …
        # }
        # bats is very picky about the {} block (and the newlines).
        (_: test: "@test ${pkgs.lib.escapeShellArg test.description} {\n${test.test}\n}"))
      (pkgs.lib.concatStringsSep "\n")
      (pkgs.writeText "testsuite")
      (test-suite: writeExecline name {} [
        batsParallel
        # this executes 4 tasks in parrallel, which requires them to not depend on each other
        "--jobs" "4"
        test-suite ])
    ];

  testsuite = batsScript "run-testsuite" tests;

in {
  inherit
    mdsh-sandbox testsuite tests;
}
