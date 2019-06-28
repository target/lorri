#!/bin/sh

set -eu

cargo build
carnix generate-nix --src .
