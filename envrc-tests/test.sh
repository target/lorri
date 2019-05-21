#!/usr/bin/env bash

set -eu

readonly ENVRC=$(dirname "$0")/../src/ops/direnv/envrc.bash

readonly scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
function finish {
    rm -rf "$scratch"
}
trap finish EXIT

check() {
    rm -rf "$scratch"
    mkdir "$scratch"
    touch "$scratch/varmap"
    echo "Test: $@"
}

with() (
    env -i bash -c \
        '
          envs=$1
          shift
          [ -f "$envs" ] && . "$envs"
          export "$@"
          export > "$envs"
        ' \
        -- "$scratch/ambient-environment" "$@"
)


env_exports() (
    env -i bash -c \
        '
          envs=$1
          shift
          [ -f "$envs" ] && . "$envs"
          export "$@"
          export > "$envs"
        ' \
        -- "$scratch/bash-export" "$@"
)

and_varmap() {
    printf "%s\t%s\t%s\n" "$1" "$2" "$3" >> "$scratch/varmap"
}

var_test() (
    msg=$1
    shift

    echo -n "~~> $msg ... "
    env -i bash -c \
        '
          set -eu
          envrc=$1
          shift
          scratch=$1
          export EVALUATION_ROOT=$scratch
          shift
          var=$1
          shift
          . "$scratch/ambient-environment"
          . "$envrc"
          if test "${!var:-}" "$@"; then
            echo "OK"
            exit 0
          else
            echo "FAILED: $?"
            echo "Checking ${var}" "$@"
            echo "Found: «${!var:-}»"
            exit 1
          fi
        ' \
            -- "$ENVRC" "$scratch" "$@"
)

(
    check "Nix's default nix-shell variables are updated like upstream's"
    with HOME=/home/alice
    with USER=alice
    with PATH=/run/current-system/bin

    env_exports HOME=/homeless-shelter
    env_exports USER=nixbld1
    env_exports PATH=/foo/bar/path

    var_test "don't update HOME" HOME = "/home/alice"
    var_test "don't update USER" USER = "alice"
    var_test "PATH is prepended" PATH = "/foo/bar/path:/run/current-system/bin"
)

(
    check "Arbitrary variables are overridden"

    with FOOBAR=BAZ
    env_exports FOOBAR=TUX
    var_test "FOOBAR is replaced" FOOBAR = "TUX"
)

(
    check "#23: The varmap is consulted when importing unknown variables"

    with GOPATH=/pathA
    env_exports GOPATH=/pathB
    and_varmap append GOPATH :

    var_test "GOPATH is extended with :" GOPATH = "/pathA:/pathB"
)
