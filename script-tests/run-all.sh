#! /usr/bin/env nix-shell
#! nix-shell ../shell.nix -i sh --arg isDevelopmentShell false
# shellcheck shell=sh

set -eux

shellcheck "$0"

cd "$(dirname "$0")"

shellcheck ../nix/bogus-nixpkgs/builder.sh
shellcheck ../src/ops/direnv/envrc.bash
