#!/usr/bin/env sh

set -eu

# copy post-build-hook script to /etc/nix
sudo cp ./.github/workflows/nix-cachix-post-build-hook.sh /etc/nix/
sudo chmod a+x /etc/nix/nix-cachix-post-build-hook.sh

# append the post-build-hook
sudo sh -c 'echo "post-build-hook = /etc/nix/nix-cachix-post-build-hook.sh" >> /etc/nix/nix.conf'
sudo sh -c 'echo "frblbaz = hihihi" >> /etc/nix/nix.conf'

echo "/etc/nix/nix.conf:"
cat /etc/nix/nix.conf
echo

echo "/etc/nix/nix-cachix-post-build-hook.sh:"
cat /etc/nix/nix-cachix-post-build-hook.sh
echo

nix show-config
