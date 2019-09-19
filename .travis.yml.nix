let
  pkgs = import ./nix/nixpkgs.nix {};

  projectname = "lorri";

  cachix-queue-file = "$HOME/push-to-cachix";

  hosts = {
    linux = {
      os = "linux";
      language = "nix";
      nix = "2.2.1";
    };

    macos = {
      os = "osx";
      language = "nix";
      nix = "2.0";
    };
  };

  scripts = {
    builds = {
      name = "nix-build";
      script = [
        ''
          set -e
          source ./.travis_fold.sh
          lorri_travis_fold lorri-nix-build \
            nix-build
          lorri_travis_fold lorri-install \
            nix-env -i ./result
          lorri_travis_fold lorri-self-upgrade \
            lorri self-upgrade local $(pwd)
        ''
        # push build closure to cachix
        ''readlink ./result >> ${cachix-queue-file}''
      ];
    };

    lints = {
      name = "cargo build & linters";
      script = [
        ''
          set -e
          export LC_ALL=C.UTF-8
          export LC_CTYPE=C.UTF-8
          export LANG=C.UTF-8
          export LANGUAGE=C.UTF-8
          source ./.travis_fold.sh

          lorri_travis_fold travis-yml-gen \
            cat $(nix-build --quiet ./.travis.yml.nix --no-out-link) > .travis.yml
          lorri_travis_fold travis-yml-idempotent \
            git diff -q ./.travis.yml

          testsuite=$(mktemp)
          lorri_travis_fold ci_check \
            (nix-build --arg isDevelopmentShell false -A ci.testsuite shell.nix > "$testsuite")
          eval $(cat "$testsuite")
        ''
        # push test suite closure to cachix
        ''printf '%s' "$testsuite" >> ${cachix-queue-file}''
      ];
    };

    # cache rust dependency building
    cache = name: {
      before_cache =
        let rmTarget = path: ''rm -rvf "$TRAVIS_BUILD_DIR/target/debug/${path}"'';
        # delete all our own artifacts from the cache dir
        # based on https://gist.github.com/jkcclemens/000456ca646bd502cac0dbddcb8fa307
        in (map rmTarget [
          "lib${projectname}.rlib"
          # our own binaries/libraries (keep all other deps)
          "${projectname}*"
          "build/${projectname}-*"
          "deps/${projectname}-*"
          "deps/lib${projectname}-*"
          "incremental/${projectname}-*"
          ".fingerprint/${projectname}-*"
          # build script executable
          "incremental/build_script_build-*"
          # TODO: the direnv integration test is not deterministic
          "direnv-*"
          "deps/direnv-*"
          "incremental/direnv-*"
        ]);
        # TODO: this might improve things, but we don’t want
        # to open another `nix-shell` (because it takes a few seconds)
        # ++ [ "cargo clean -p ${projectname}" ];
      cache.directories = [ "$HOME/.cargo" "$TRAVIS_BUILD_DIR/target" ];
      env = [ "CACHE_NAME=${name}" ];
    };

    setup-cachix =
      let cachix-repo = "lorri-test";
      in {
        install = [
          # install cachix
          ''nix-env -iA cachix -f https://cachix.org/api/v1/install''
          # setup cachix
          ''cachix use ${cachix-repo}''
          # set cachix into watch-mode (listen for new paths and push in the background)
        ];

        before_cache = [
          # read every store path written by previous phases
          # from the cachix-queue-file file and push to cachix
          ''echo "pushing these paths to cachix:"''
          ''cat ${cachix-queue-file}''
          ''cachix push ${cachix-repo} < ${cachix-queue-file}''
        ];
      };

      macos-cachix-fix = {
        # fix on MacOS with cachix v3 (2019-09-20)
        # see https://github.com/cachix/cachix/issues/228#issuecomment-531165065
        install = [
          ''echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf''
          ''sudo launchctl kickstart -k system/org.nixos.nix-daemon || true''
        ];
      };
  };

  jobs =
    let
      # merge the given attributesets;
      # lists are concatenated, everything else is an error.
      # This is // but with merging of lists (left to right).
      mergeShallowConcatLists = pkgs.lib.zipAttrsWith
        (_: values:
          let first = builtins.head values; in
          if builtins.length values == 1 then first else
          if builtins.isList first
          then builtins.concatLists values
          else abort "can only merge lists for now");
    in
    {
      git.depth = false;
      language = "nix";
      matrix.include = map mergeShallowConcatLists [
        # Verifying lints on macOS and Linux ensures nix-shell works
        # on both platforms.
        [ hosts.linux scripts.setup-cachix scripts.lints (scripts.cache "linux") ]
        # cachix 3 on macOS is broken on travis, see
        # https://github.com/cachix/cachix/issues/228#issuecomment-533634704
        [ hosts.macos /*scripts.macos-cachix-fix scripts.setup-cachix*/ scripts.lints (scripts.cache "macos") ]

        [ hosts.linux scripts.setup-cachix scripts.builds ]
        # cachix 3 on macOS is broken on travis, see
        # https://github.com/cachix/cachix/issues/228#issuecomment-533634704
        [ hosts.macos /*scripts.macos-cachix-fix scripts.setup-cachix*/ scripts.builds ]
      ];
    };
in pkgs.runCommand "travis.yml" {
  # TODO: move to yj (in newer nixpkgs)
  # is a statically compiled golang package,
  # so doesn’t incur a dependency on python
  buildInputs = [ pkgs.remarshal ];
  passAsFile = [ "jobs" ];
  jobs = builtins.toJSON jobs;
  preferLocalBuild = true;
  allowSubstitutes = false;
}
''
  remarshal -if json -i $jobsPath -of yaml -o $out --yaml-style ">"
''
