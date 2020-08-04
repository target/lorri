{ pkgs ? import ../../nix/nixpkgs-stable.nix }:
let
  setup-cachix = {
    name = "Cachix";
    uses = "cachix/cachix-action@v6";
    "with" = {
      name = "lorri-test";
      signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
    };
  };

  config = {
    name = "CI";
    on = {
      pull_request = { branches = [ "**" ]; };
      push = { branches = [ "master" ]; };
    };
    env = { LORRI_NO_INSTALL_PANIC_HANDLER = "absolutely"; };
    jobs = {
      rust = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v2";
          }
          {
            name = "Nix";
            uses = "cachix/install-nix-action@v9";
            "with" = {
              skip_adding_nixpkgs_channel = true;
            };
          }
          setup-cachix
          {
            name = "Cache cargo registry";
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-registry-\${{ hashFiles('**/Cargo.lock') }}";
              path = "~/.cargo/registry";
            };
          }
          {
            name = "Cache cargo index";
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-index-\${{ hashFiles('**/Cargo.lock') }}";
              path = "~/.cargo/git";
            };
          }
          {
            name = "Cache cargo build";
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-build-target-\${{ hashFiles('**/Cargo.lock') }}";
              path = "target";
            };
          }
          {
            name = "Shell (cache inputs)";
            run = "nix-shell";
          }
          {
            name = "CI check";
            run = "nix-shell --arg isDevelopmentShell false --run 'ci_check'";
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-build_stable = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v2";
            "with" = {
              fetch-depth = 0;
            };
          }
          {
            name = "Nix";
            uses = "cachix/install-nix-action@v9";
            "with" = {
              skip_adding_nixpkgs_channel = true;
            };
          }
          setup-cachix
          { name = "Build"; run = "nix-build"; }
          {
            name = "Install";
            run = "nix-env -i ./result";
          }
          {
            name = "Self-upgrade";
            run = "lorri self-upgrade local \$(pwd)";
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-build_1909 = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v2";
          }
          {
            name = "Nix";
            uses = "cachix/install-nix-action@v9";
            "with" = {
              skip_adding_nixpkgs_channel = true;
            };
          }
          setup-cachix
          {
            name = "Build";
            run = "nix-build --arg nixpkgs ./nix/nixpkgs-1909.nix";
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-shell = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v2";
          }
          {
            name = "Nix";
            uses = "cachix/install-nix-action@v9";
            "with" = {
              skip_adding_nixpkgs_channel = true;
            };
          }
          setup-cachix
          {
            name = "Build";
            run = "nix-build -A allBuildInputs shell.nix";
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      overlay = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v2";
          }
          {
            name = "Nix";
            uses = "cachix/install-nix-action@v9";
            "with" = {
              skip_adding_nixpkgs_channel = true;
            };
          }
          setup-cachix
          {
            name = "Build w/ overlay (19.09)";
            run = "nix-build ./nix/overlay.nix -A lorri --arg pkgs ./nix/nixpkgs-1909.json";
          }
          {
            name = "Build w/ overlay (stable)";
            run = "nix-build ./nix/overlay.nix -A lorri --arg pkgs ./nix/nixpkgs-stable.json";
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
    };
  };

  yaml = pkgs.runCommand "ci.yml" {
    buildInputs = [ pkgs.yj ];
    passAsFile = [ "config" ];
    config = builtins.toJSON config;
    preferLocalBuild = true;
    allowSubstitutes = false;
  }
    ''
      yj -jy < $configPath > $out
    '';

  # writes the file to the right path (toString is the absolute local path)
  writeConfig = pkgs.writers.writeDash "write-ci.yml" ''
    cat "${yaml}" > "${toString ./ci.yml}"
  '';
in
writeConfig
