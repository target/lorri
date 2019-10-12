{ pkgs, LORRI_ROOT, BUILD_REV_COUNT, RUN_TIME_CLOSURE, rust}:
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
    "foreground" [ "${pkgs.coreutils}/bin/echo" "shellchecking ${file}" ]
    "${pkgs.shellcheck}/bin/shellcheck" "--shell" "bash" file
  ];

  cargoEnvironment =
    # we have to add the bin to PATH,
    # otherwise cargo doesn’t find its subcommands
    [ (pathAdd "prepend") (pkgs.lib.makeBinPath [ rust pkgs.gcc ])
      "export" "BUILD_REV_COUNT" (toString BUILD_REV_COUNT)
      "export" "RUN_TIME_CLOSURE" RUN_TIME_CLOSURE ];

  cargo = name: setup: args:
    writeExecline name {} (cargoEnvironment ++ setup ++ [ "cargo" ] ++ args);

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
      test = cargo "lint-cargo-fmt" [] [ "fmt" "--" "--check" ];
    };

    cargo-test = {
      description = "run cargo test";
      test = cargo "cargo-test"
        # the tests need bash and nix and direnv
        [ (pathAdd "prepend") (pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.bash pkgs.nix pkgs.direnv ]) ]
        [ "test" ];
    };

    cargo-clippy = {
      description = "run cargo clippy";
      test = cargo "cargo-clippy" [ "export" "RUSTFLAGS" "-D warnings" ] [ "clippy" ];
    };

    # TODO: it would be good to sandbox this (it changes files in the tree)
    # but somehow carnix needs to compile the whole friggin binary in order
    # to generate a few measly nix files …
    carnix = {
      description = "check carnix up-to-date";
      test = writeExecline "lint-carnix" {}
        (cargoEnvironment
        ++ [
          (pathAdd "prepend") (pkgs.lib.makeBinPath [ pkgs.carnix ])
          "if" [ pkgs.runtimeShell "${LORRI_ROOT}/nix/update-carnix.sh" ]
          "${pkgs.gitMinimal}/bin/git" "diff" "--exit-code"
        ]);
    };

  };

  # clean the environment;
  # this is the only way we can have a non-diverging
  # environment between developer machine and CI
  emptyTestEnv = test:
    writeExecline "${test.name}-empty-env" {}
      [ (runInEmptyEnv []) test ];

  testsWithEmptyEnv = pkgs.lib.mapAttrs
    (_: test: test // { test = emptyTestEnv test.test; }) tests;

  # Write a attrset which looks like
  # { "test description" = test-script-derviation }
  # to a script which can be read by `bats` (a simple testing framework).
  batsScript =
    let
      # add a few things to bats’ path that should really be patched upstream instead
      # TODO: upstream
      bats = writeExecline "bats" {} [
        (pathAdd "prepend") (pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep ])
        "${pkgs.bats}/bin/bats" "$@"
      ];
      # see https://github.com/bats-core/bats-core/blob/f3a08d5d004d34afb2df4d79f923d241b8c9c462/README.md#file-descriptor-3-read-this-if-bats-hangs
      closeFD3 = "3>&-";
    in name: tests: pkgs.lib.pipe testsWithEmptyEnv [
      (pkgs.lib.mapAttrsToList
        # a bats test looks like:
        # @test "name of test" {
        #   … test code …
        # }
        # bats is very picky about the {} block (and the newlines).
        (_: test: "@test ${pkgs.lib.escapeShellArg test.description} {\n${test.test} ${closeFD3}\n}"))
      (pkgs.lib.concatStringsSep "\n")
      (pkgs.writeText "testsuite")
      (test-suite: writeExecline name {} [
        bats test-suite
      ])
    ];

  testsuite = batsScript "run-testsuite" tests;

in {
  inherit testsuite;
  # we want the single test attributes to have their environment emptied as well.
  tests = testsWithEmptyEnv;
}
