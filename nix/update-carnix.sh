#!/bin/sh

set -eu

cargo build
carnix generate-nix --src .
mv ./crates-io.nix ./Cargo.nix ./nix/carnix/
