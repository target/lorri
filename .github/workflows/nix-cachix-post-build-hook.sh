#!/usr/bin/env bash
set -eu
set -f # disable globbing
export IFS=' '

echo "Uploading to cache: " $OUT_PATHS

exec \
    cachix push $OUT_PATHS
