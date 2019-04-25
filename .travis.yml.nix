let
  pkgs = import <nixpkgs> {};

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
        travis_fold lorri-nix-build \
          nix-build
        travis_fold lorri-install \
          nix-env -i ./result
        travis_fold lorri-self-upgrade \
          lorri self-upgrade local $(pwd)
      '';
    };

    lints = {
      name = "cargo build & linters";
      script = ''
        set -e
        source ./.travis_fold.sh
        travis_fold ci_check \
          nix-shell --run ci_check
        travis_fold travis-yml-gen \
          cat $(nix-build ./.travis.yml.nix --no-out-link) > .travis.yml
        travis_fold travis-yml-idempotent \
          git diff -q ./.travis.yml
      '';
    };
  };

  jobs = {
    git.depth = false;
    languge = "nix";
    matrix.include = [
      # Verifying lints on macOS and Linux ensures nix-shell works
      # on both platforms.
      (hosts.linux // scripts.lints)
      (hosts.macos // scripts.lints)

      (hosts.linux // scripts.builds)
      (hosts.macos // scripts.builds)
    ];
  };
in pkgs.runCommand "travis.yml" {
  buildInputs = [ pkgs.remarshal ];
  passAsFile = [ "jobs" ];
  jobs = builtins.toJSON jobs;
}
''
  remarshal -if json -i $jobsPath -of yaml -o $out --yaml-style ">"
''
