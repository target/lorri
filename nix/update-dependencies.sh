#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git jq

set -euo pipefail

nix-prefetch-git https://github.com/nixos/nixpkgs-channels.git \
                 --rev refs/heads/nixos-unstable > ./nix/nixpkgs.json

cat > ./nix/rust-channels.nix <<EOF
{ stableVersion }:
{
  nightly = {
    channel = "nightly";
    date = "$(date --date yesterday +%Y-%m-%d)";
  };
  stable = {
    channel = stableVersion;
  };
}
EOF

