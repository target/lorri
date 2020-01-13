let
  pkgs = import ./nix/nixpkgs.nix;

  projectname = "lorri";

  cachix-queue-file = "$HOME/push-to-cachix";
  cachix-repo = "lorri-test";
  # cachix 3 on macOS is broken on travis, see
  # https://github.com/cachix/cachix/issues/228#issuecomment-533634704
  pushToCachix = { isDarwin }: cachix-queue-file: if isDarwin then [] else [
    # read every store path written by previous phases
    # from the cachix-queue-file file and push to cachix
    ''echo "pushing these paths to cachix:"''
    ''cat ${cachix-queue-file}''
    ''
      if [ -n "$CACHIX_SIGNING_KEY" ]; then
        cachix push ${cachix-repo} < ${cachix-queue-file}
      fi
    ''
  ];

  hosts = {
    linux = {
      os = "linux";
      language = "nix";
      nix = "2.3.1";
    };

    macos = {
      os = "osx";
      #language = "nix";
      #nix = "2.3.1";
      before_install = [
        ''wget --retry-connrefused --waitretry=1 -O /tmp/nix-install https://nixos.org/releases/nix/nix-2.3.1/install''
        ''yes | sh /tmp/nix-install --daemon''
        ''
          if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          elif [ -f ''${TRAVIS_HOME}/.nix-profile/etc/profile.d/nix.sh ]; then
            source source ''${TRAVIS_HOME}/.nix-profile/etc/profile.d/nix.sh
          fi
        ''
      ];
    };
  };

  scripts = {
    builds = { isDarwin ? false }: {
      name = "nix-build";
      script = [
        ''set -e''
        ''nix-build''
        ''nix-env -i ./result''
      ]
      # push build closure to cachix
      ++ [ ''readlink ./result > ./cachix-file'' ]
      ++ pushToCachix { inherit isDarwin; } "./cachix-file"
      # test lorri self-upgrade
      ++ [ ''lorri self-upgrade local $(pwd)'' ];
    };

    lints = { isDarwin ? false }: {
      name = "cargo build & linters";
      script = [
        ''set -e''
        ''nix-build -A allBuildInputs shell.nix > ./shell-inputs''
      ]
      ++ pushToCachix { inherit isDarwin; } "./shell-inputs"
      ++ (
        let
          # Cachix is broken on macOS [1] and clippy is not built by Hydra [2].
          # To avoid building clippy on macOS in CI, which takes about 25
          # minutes, we don't run lints (which require clippy) on macOS.
          # Instead we run only ci_test.
          #
          # On Linux, we run ci_check, which itself runs both ci_test and ci_lint.
          #
          # [1] https://github.com/cachix/cachix/issues/228#issuecomment-533634704
          # [2] https://github.com/NixOS/nixpkgs/issues/77358
          script = if isDarwin then "ci_test" else "ci_check";
        in
          [
            ''nix-shell --quiet --arg isDevelopmentShell false --run ${script}''
            ''cat $(nix-build --quiet ./.travis.yml.nix --no-out-link) > .travis.yml''
            ''git diff -q ./.travis.yml''
            ''git diff -q ./Cargo.nix''
            ''git diff -q ./src/com_target_lorri.rs''
          ]
      );
    };

    # cache rust dependency building
    cache = name: {
      # delete all our own artifacts from the cache dir
      # based on https://gist.github.com/jkcclemens/000456ca646bd502cac0dbddcb8fa307
      before_cache =
        let
          rmTarget = path: ''rm -rvf "$TRAVIS_BUILD_DIR/target/debug/${path}"'';
        in
          (
            map rmTarget [
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
            ]
          );
      # TODO: this might improve things, but we don’t want
      # to open another `nix-shell` (because it takes a few seconds)
      # ++ [ "cargo clean -p ${projectname}" ];
      cache.directories = [ "$HOME/.cargo" "$TRAVIS_BUILD_DIR/target" ];
      env = [ "CACHE_NAME=${name}" ];
    };

    setup-cachix =
      {
        install = [
          # install cachix
          ''nix-env -iA cachix -f https://cachix.org/api/v1/install''
          # setup cachix
          ''cachix use ${cachix-repo}''
          # set cachix into watch-mode (listen for new paths and push in the background)
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
        (
          _: values:
            let
              first = builtins.head values;
            in
              if builtins.length values == 1 then first else
                if builtins.isList first
                then builtins.concatLists values
                else abort "can only merge lists for now"
        );
    in
      {
        git.depth = false;
        language = "minimal";
        matrix.include = map mergeShallowConcatLists [
          # Verifying lints on macOS and Linux ensures nix-shell works
          # on both platforms.
          [ hosts.linux scripts.setup-cachix (scripts.lints {}) (scripts.cache "linux") ]
          # cachix 3 on macOS is broken on travis, see
          # https://github.com/cachix/cachix/issues/228#issuecomment-533634704
          [ hosts.macos /*scripts.macos-cachix-fix scripts.setup-cachix*/ (scripts.lints { isDarwin = true; }) (scripts.cache "macos") ]

          [ hosts.linux scripts.setup-cachix (scripts.builds {}) ]
          # cachix 3 on macOS is broken on travis, see
          # https://github.com/cachix/cachix/issues/228#issuecomment-533634704
          [ hosts.macos /*scripts.macos-cachix-fix scripts.setup-cachix*/ (scripts.builds { isDarwin = true; }) ]
        ];
      };
in
pkgs.runCommand "travis.yml" {
  buildInputs = [ pkgs.yj ];
  passAsFile = [ "jobs" ];
  jobs = builtins.toJSON jobs;
  preferLocalBuild = true;
  allowSubstitutes = false;
}
  ''
    yj -jy < $jobsPath > $out
  ''
