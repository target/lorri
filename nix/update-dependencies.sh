#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git jq

set -euo pipefail

# lorri should always build with the current NixOS stable branch.
channel='nixos-20.03'
nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev "refs/heads/${channel}" > ./nix/nixpkgs.json

