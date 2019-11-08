{ pkgs, LORRI_ROOT, BUILD_REV_COUNT, RUN_TIME_CLOSURE, rust }:
let

  lorriBinDir = "${LORRI_ROOT}/target/debug";

  inherit (import ./execline.nix { inherit pkgs; })
    writeExecline;

  inherit (import ./lib.nix { inherit pkgs writeExecline; })
    allCommandsSucceed
    pathAdd pathPrependBins;

  inherit (import ./sandbox.nix { inherit pkgs writeExecline; })
    runInEmptyEnv;

  # shellcheck a file
  shellcheck = file: writeExecline "lint-shellcheck" {} [
    "cd" LORRI_ROOT
    "foreground" [ "${pkgs.coreutils}/bin/echo" "shellchecking ${file}" ]
    "${pkgs.shellcheck}/bin/shellcheck" "--shell" "bash" file
  ];

  # Dump the environment inside a `stdenv.mkDerivation` builder
  # into an envdir (can be read in again with `s6-envdir`).
  # This captures all magic `setupHooks` and linker paths and the like.
  stdenvDrvEnvdir = { unsetVars }: drvAttrs: pkgs.stdenv.mkDerivation ({
    name = "dumped-env";
    phases = [ "buildPhase" ];
    buildPhase = ''
      mkdir $out
      unset HOME TMP TEMP TEMPDIR TMPDIR
      # unset user-requested variables as well
      unset ${pkgs.lib.concatStringsSep " " unsetVars}
      ${pkgs.s6-portable-utils}/bin/s6-dumpenv $out
    '';
  } // drvAttrs);

  # On darwin we have to get the system libraries
  # from their setup hooks, by exporting the variables
  # from the builder.
  # Otherwise building & linking the rust binaries fails.
  darwinImpureEnv =
    stdenvDrvEnvdir
      # if this is set, the non-sandboxed build complains about
      # linker paths outside of the nix store.
      { unsetVars = [ "NIX_ENFORCE_PURITY" "NIX_SSL_CERT_FILE" "SSL_CERT_FILE" ]; }
      {
        buildInputs = [
          # TODO: duplicated in shell.nix and default.nix
          pkgs.darwin.Security
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.CoreServices
          pkgs.darwin.apple_sdk.frameworks.CoreFoundation
          pkgs.stdenv.cc.bintools.bintools
        ];
      };

  cargoEnvironment =
    # on darwin, this sets the environment to a normal builder environment.
    (pkgs.lib.optionals pkgs.stdenv.isDarwin [
       "importas" "OLDPATH" "PATH"
       "${pkgs.s6}/bin/s6-envdir" darwinImpureEnv
       (pathAdd "prepend") "$OLDPATH"
       # TODO: duplicated in default.nix
       # Cargo wasn't able to find CF during a `cargo test` run on Darwin.
       # see https://stackoverflow.com/questions/51161225/how-can-i-make-macos-frameworks-available-to-clang-in-a-nix-environment
       "importas" "NIX_LDFLAGS" "NIX_LDFLAGS"
       "export" "NIX_LDFLAGS" "-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation \${NIX_LDFLAGS}"
    ])
    ++ (pathPrependBins [
          rust
          pkgs.stdenv.cc
          # ar
          pkgs.binutils-unwrapped
        ])
    ++ [
      "export" "RUST_BACKTRACE" "1"
      "export" "BUILD_REV_COUNT" (toString BUILD_REV_COUNT)
      "export" "RUN_TIME_CLOSURE" RUN_TIME_CLOSURE
      "if" [ "${pkgs.coreutils}/bin/env" ]

    ];

  writeCargo = name: setup: args:
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
      test = writeCargo "lint-cargo-fmt" [] [ "fmt" "--" "--check" ];
    };

    cargo-test = {
      description = "run cargo test";
      test = writeCargo "cargo-test"
        # the tests need bash and nix and direnv
        (pathPrependBins [ pkgs.coreutils pkgs.bash pkgs.nix pkgs.direnv ])
        [ "test" ];
    };

    cargo-clippy = {
      description = "run cargo clippy";
      test = writeCargo "cargo-clippy" [ "export" "RUSTFLAGS" "-D warnings" ] [ "clippy" ];
    };

    # TODO: it would be good to sandbox this (it changes files in the tree)
    # but somehow carnix needs to compile the whole friggin binary in order
    # to generate a few measly nix files …
    carnix = {
      description = "check carnix up-to-date";
      test = writeExecline "lint-carnix" {}
        (cargoEnvironment
        ++ pathPrependBins [
             pkgs.carnix
             # TODO: nix-prefetch-* should be patched into carnix
             pkgs.nix-prefetch-scripts
             # nix-prefetch-url, which itself requires tar and gzip
             pkgs.nix pkgs.gnutar pkgs.gzip
           ]
        ++ [
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
      [ (runInEmptyEnv [ "USER" "HOME" "TERM" ]) test ];

  testsWithEmptyEnv = pkgs.lib.mapAttrs
    (_: test: test // { test = emptyTestEnv test.test; }) tests;

  # Write a attrset which looks like
  # { "test description" = test-script-derviation }
  # to a script which can be read by `bats` (a simple testing framework).
  batsScript =
    let
      # add a few things to bats’ path that should really be patched upstream instead
      # TODO: upstream
      bats = writeExecline "bats" {}
        (pathPrependBins [ pkgs.coreutils pkgs.gnugrep ]
        ++ [ "${pkgs.bats}/bin/bats" "$@" ]);
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
  inherit darwinImpureEnv;
}
