{ pkgs ? import ../../nix/nixpkgs-stable.nix }:
let
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
            run = null;
            uses = "actions/checkout@v2";
            "with" = null;
          }
          {
            name = "Nix";
            run = null;
            uses = "cachix/install-nix-action@v9";
            "with" = {
              key = null;
              name = null;
              path = null;
              signingKey = null;
              skipPush = null;
              skip_adding_nixpkgs_channel = true;
            };
          }
          {
            name = "Cachix";
            run = null;
            uses = "cachix/cachix-action@v6";
            "with" = {
              key = null;
              name = "lorri-test";
              path = null;
              signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Cache cargo registry";
            run = null;
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-registry-\${{ hashFiles('**/Cargo.lock') }}";
              name = null;
              path = "~/.cargo/registry";
              signingKey = null;
              skipPush = null;
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Cache cargo index";
            run = null;
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-index-\${{ hashFiles('**/Cargo.lock') }}";
              name = null;
              path = "~/.cargo/git";
              signingKey = null;
              skipPush = null;
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Cache cargo build";
            run = null;
            uses = "actions/cache@v1";
            "with" = {
              key = "\${{ runner.os }}-cargo-build-target-\${{ hashFiles('**/Cargo.lock') }}";
              name = null;
              path = "target";
              signingKey = null;
              skipPush = null;
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Shell (cache inputs)";
            run = "nix-shell";
            uses = null;
            "with" = null;
          }
          {
            name = "CI check";
            run = "nix-shell --arg isDevelopmentShell false --run 'ci_check'";
            uses = null;
            "with" = null;
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-build_stable = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            run = null;
            uses = "actions/checkout@v2";
            "with" = {
              fetch-depth = 0;
              name = null;
              signingKey = null;
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Nix";
            run = null;
            uses = "cachix/install-nix-action@v9";
            "with" = {
              fetch-depth = null;
              name = null;
              signingKey = null;
              skip_adding_nixpkgs_channel = true;
            };
          }
          {
            name = "Cachix";
            run = null;
            uses = "cachix/cachix-action@v6";
            "with" = {
              fetch-depth = null;
              name = "lorri-test";
              signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              skip_adding_nixpkgs_channel = null;
            };
          }
          { name = "Build"; run = "nix-build"; uses = null; "with" = null; }
          {
            name = "Install";
            run = "nix-env -i ./result";
            uses = null;
            "with" = null;
          }
          {
            name = "Self-upgrade";
            run = "lorri self-upgrade local \$(pwd)";
            uses = null;
            "with" = null;
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-build_1909 = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            run = null;
            uses = "actions/checkout@v2";
            "with" = null;
          }
          {
            name = "Nix";
            run = null;
            uses = "cachix/install-nix-action@v9";
            "with" = {
              name = null;
              signingKey = null;
              skip_adding_nixpkgs_channel = true;
            };
          }
          {
            name = "Cachix";
            run = null;
            uses = "cachix/cachix-action@v6";
            "with" = {
              name = "lorri-test";
              signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Build";
            run = "nix-build --arg nixpkgs ./nix/nixpkgs-1909.nix";
            uses = null;
            "with" = null;
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      nix-shell = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            run = null;
            uses = "actions/checkout@v2";
            "with" = null;
          }
          {
            name = "Nix";
            run = null;
            uses = "cachix/install-nix-action@v9";
            "with" = {
              name = null;
              signingKey = null;
              skip_adding_nixpkgs_channel = true;
            };
          }
          {
            name = "Cachix";
            run = null;
            uses = "cachix/cachix-action@v6";
            "with" = {
              name = "lorri-test";
              signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Build";
            run = "nix-build -A allBuildInputs shell.nix";
            uses = null;
            "with" = null;
          }
        ];
        strategy = { matrix = { os = [ "ubuntu-latest" "macos-latest" ]; }; };
      };
      overlay = {
        runs-on = "\${{ matrix.os }}";
        steps = [
          {
            name = "Checkout";
            run = null;
            uses = "actions/checkout@v2";
            "with" = null;
          }
          {
            name = "Nix";
            run = null;
            uses = "cachix/install-nix-action@v9";
            "with" = {
              name = null;
              signingKey = null;
              skip_adding_nixpkgs_channel = true;
            };
          }
          {
            name = "Cachix";
            run = null;
            uses = "cachix/cachix-action@v6";
            "with" = {
              name = "lorri-test";
              signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              skip_adding_nixpkgs_channel = null;
            };
          }
          {
            name = "Build w/ overlay (19.09)";
            run = "nix-build ./nix/overlay.nix -A lorri --arg pkgs ./nix/nixpkgs-1909.json";
            uses = null;
            "with" = null;
          }
          {
            name = "Build w/ overlay (stable)";
            run = "nix-build ./nix/overlay.nix -A lorri --arg pkgs ./nix/nixpkgs-stable.json";
            uses = null;
            "with" = null;
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
