#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git jq

set -euo pipefail

nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev refs/heads/nixos-unstable > ./nix/nixpkgs.json
nix-prefetch-git https://github.com/mozilla/nixpkgs-mozilla.git \
                 --rev refs/heads/master > ./nix/nixpkgs-mozilla.json

cat > ./nix/rust-nightly.nix <<EOF
{
  channel = "nightly";
  date = "$(date --date yesterday +%Y-%m-%d)";
}
EOF

