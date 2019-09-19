{ pkgs, LORRI_ROOT, rust}:
let

  lorriBinDir = "${LORRI_ROOT}/target/debug";

  inherit (import ./execline.nix { inherit pkgs; })
    writeExecline;

  inherit (import ./lib.nix { inherit pkgs writeExecline; })
    allCommandsSucceed pathAdd;

  inherit (import ./sandbox.nix { inherit pkgs writeExecline; })
    runInEmptyEnv;

  # shellcheck a file
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

    # TODO: it would be good to sandbox this (it changes files in the tree)
    # but somehow carnix needs to compile the whole friggin binary in order
    # to generate a few measly nix files …
    carnix = {
      description = "check carnix up-to-date";
      test = writeExecline "lint-carnix" {} [
        "if" [ pkgs.runtimeShell "${LORRI_ROOT}/nix/update-carnix.sh" ]
        "${pkgs.git}/bin/git" "diff" "--exit-code"
      ];
    };

  };

  # Write a attrset which looks like
  # { "test description" = test-script-derviation }
  # to a script which can be read by `bats` (a simple testing framework).
  batsScript =
    name: tests: pkgs.lib.pipe tests [
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
      # clean the environment;
      # this is the only way we can have a non-diverging
      # environment between developer machine and CI
      (runInEmptyEnv [])
      "${pkgs.bats}/bin/bats"
      test-suite ])
    ];

  testsuite = batsScript "run-testsuite" tests;

in {
  inherit
    testsuite tests;
}
