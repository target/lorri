#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git jq

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# lorri should always build with the current NixOS stable branch.
channel='nixos-20.03'
nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev "refs/heads/${channel}" > $DIR/nixpkgs.json

nix-prefetch-git https://github.com/mozilla/nixpkgs-mozilla.git \
                 --rev "refs/heads/master" > $DIR/mozilla.json

