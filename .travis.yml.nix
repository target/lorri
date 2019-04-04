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
        nix-build
        nix-env -i ./result
        lorri self-upgrade local $(pwd)
      '';
    };

    lints = {
      name = "cargo build & linters";
      script = ''
        set -e
        nix-shell --run ci_check
        cat $(nix-build ./.travis.yml.nix --no-out-link) > .travis.yml
        git diff -q ./.travis.yml
      '';
    };
  };

  jobs = {
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
  remarshal -if json -i $jobsPath -of yaml -o $out
''
