#!/bin/sh

set -eux

shellcheck "$0"

cd "$(dirname "$0")"

shellcheck ./envrc.sh
shellcheck ../nix/bogus-nixpkgs/builder.sh
shellcheck ../src/ops/prompt.sh
shellcheck ../src/ops/direnv/envrc.bash

./envrc.sh
