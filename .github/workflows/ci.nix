{ pkgs ? import ../../nix/nixpkgs-stable.nix }:
let
  checkout = { fetch-depth ? null }: {
    name = "Checkout";
    uses = "actions/checkout@v2";
    "with" = {
      inherit fetch-depth;
    };
  };
  setup-nix = {
    name = "Nix";
    uses = "cachix/install-nix-action@v11";
  };
  setup-cachix = {
    name = "Cachix";
    uses = "cachix/cachix-action@v6";
    "with" = {
      name = "lorri-test";
      signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
    };
  };

  rust-cache = {
    name = "Cache cargo registry";
    uses = "actions/cache@v2";
    "with" = {
      path = ''
        "~/.cargo/registry"
        "~/.cargo/git"
        "target"
      '';
      key = "\${{ runner.os }}-cargo-registry-\${{ hashFiles('**/Cargo.lock') }}";
    };
  };

  githubRunners = {
    ubuntu = "ubuntu-latest";
    macos = "macos-latest";
  };

  builds = {
    rust = { runs-on }: {
      name = "rust-${runs-on}";
      value = {
        name = "Rust and ci_check (${runs-on})";
        inherit runs-on;
        steps = [
          (checkout {})
          setup-nix
          setup-cachix
          rust-cache
          {
            name = "CI check";
            run = "nix-shell --arg isDevelopmentShell false --run 'ci_check'";
          }
        ];
      };
    };

    stable = { runs-on }: {
      name = "nix-build_stable-${runs-on}";
      value = {
        name = "nix-build [nixos stable] (${runs-on})";
        inherit runs-on;
        steps = [
          (
            checkout {
              # required for lorri self-upgrade local
              fetch-depth = 0;
            }
          )
          setup-nix
          setup-cachix
          {
            name = "Build";
            run = "nix-build";
          }
          {
            name = "Install";
            run = "nix-env -i ./result";
          }
          {
            name = "Self-upgrade";
            run = "lorri self-upgrade local \$(pwd)";
          }
        ];
      };
    };

    nixos-19_09 = { runs-on }: {
      name = "nix-build_1909-${runs-on}";
      value = {
        name = "nix-build [nixos 19.09] (${runs-on})";
        inherit runs-on;
        steps = [
          (checkout {})
          setup-nix
          setup-cachix
          {
            name = "Build";
            run = "nix-build --arg nixpkgs ./nix/nixpkgs-1909.nix";
          }
        ];
      };
    };

    overlay = { runs-on }: {
      name = "overlay-${runs-on}";
      value = {
        name = "Overlay builds (${runs-on})";
        inherit runs-on;
        steps = [
          (checkout {})
          setup-nix
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
      };
    };
  };

  config = {
    name = "CI";
    on = {
      pull_request = { branches = [ "**" ]; };
      push = { branches = [ "master" ]; };
    };
    env = { LORRI_NO_INSTALL_PANIC_HANDLER = "absolutely"; };

    jobs = builtins.listToAttrs
      [
        (builds.rust { runs-on = githubRunners.ubuntu; })
        (builds.rust { runs-on = githubRunners.macos; })
        (builds.stable { runs-on = githubRunners.ubuntu; })
        (builds.stable { runs-on = githubRunners.macos; })
        (builds.nixos-19_09 { runs-on = githubRunners.ubuntu; })
        (builds.nixos-19_09 { runs-on = githubRunners.macos; })
        (builds.overlay { runs-on = githubRunners.ubuntu; })
        (builds.overlay { runs-on = githubRunners.macos; })
      ];
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
