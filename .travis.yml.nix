let
  pkgs = import ./nix/nixpkgs.nix {};

  projectname = "lorri";

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
      script = ''
        set -e
        source ./.travis_fold.sh
        lorri_travis_fold lorri-nix-build \
          nix-build
        lorri_travis_fold lorri-install \
          nix-env -i ./result
        lorri_travis_fold lorri-self-upgrade \
          lorri self-upgrade local $(pwd)
      '';
    };

    lints = {
      name = "cargo build & linters";
      script = ''
        set -e
        source ./.travis_fold.sh

        lorri_travis_fold ci_check \
          nix-shell --quiet --arg isDevelopmentShell false --run ci_check
        lorri_travis_fold travis-yml-gen \
          cat $(nix-build --quiet ./.travis.yml.nix --no-out-link) > .travis.yml
        lorri_travis_fold travis-yml-idempotent \
          git diff -q ./.travis.yml
        lorri_travis_fold carnix-idempotent \
          git diff -q ./.travis.yml

      '';
      # delete all our own artifacts from the cache dir
      # based on https://gist.github.com/jkcclemens/000456ca646bd502cac0dbddcb8fa307
    };

    # cache rust dependency building
    cache = name: {
      before_cache =
        let rmTarget = path: ''rm -rvf "$TRAVIS_BUILD_DIR/target/debug/${path}"'';
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
  };

  jobs = {
    git.depth = false;
    languge = "nix";
    matrix.include = [
      # Verifying lints on macOS and Linux ensures nix-shell works
      # on both platforms.
      (hosts.linux // scripts.lints // (scripts.cache "linux"))
      (hosts.macos // scripts.lints // (scripts.cache "macos"))

      (hosts.linux // scripts.builds)
      (hosts.macos // scripts.builds)
    ];
  };
in pkgs.runCommand "travis.yml" {
  buildInputs = [ pkgs.remarshal ];
  passAsFile = [ "jobs" ];
  jobs = builtins.toJSON jobs;
  preferLocalBuild = true;
  allowSubstitutes = false;
}
''
  remarshal -if json -i $jobsPath -of yaml -o $out --yaml-style ">"
''
