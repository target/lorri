#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git jq

set -euo pipefail

# lorri should always build with the current NixOS stable branch.
channel='nixos-20.03'
nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev "refs/heads/${channel}" > ./nix/nixpkgs-stable.json

# lorri should also build with 19.09 (the first release with `rustPackages`,
# which we use for e.g. clippy).
min_channel='nixos-19.09'
nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev "refs/heads/${min_channel}" > ./nix/nixpkgs-1909.json
