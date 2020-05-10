#! /usr/bin/env nix-shell
#! nix-shell ../shell.nix -i sh --arg isDevelopmentShell false

set -eux

cargo build
cd nix/carnix

carnix generate-nix --src ../..
