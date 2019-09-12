#!/usr/bin/env bash
# ^ shebang is unused as this file is sourced, but present for editor
# integration. Note: Direnv guarantees it *will* be parsed using bash.

function punt () {
    :
}

# move "origPreHook" "preHook" "$@";;
move() {
    srcvarname=$1 # example: varname might contain the string "origPATH"
    # drop off the source variable name
    shift

    destvarname=$1 # example: destvarname might contain the string "PATH"
    # drop off the destination variable name
    shift

    # like: export origPATH="...some-value..."
    export "${@?}";

    # set $original to the contents of the variable $srcvarname
    # refers to
    eval "$destvarname=\"${!srcvarname}\""

    # mark the destvarname as exported so direnv picks it up
    # (shellcheck: we do want to export the content of destvarname!)
    # shellcheck disable=SC2163
    export "$destvarname"

    # remove the export from above, ie: export origPATH...
    unset "$srcvarname"
}

function prepend() {
    varname=$1 # example: varname might contain the string "PATH"

    # drop off the varname
    shift

    separator=$1 # example: separator would usually be the string ":"

    # drop off the separator argument, so the remaining arguments
    # are the arguments to export
    shift

    # set $original to the contents of the the variable $varname
    # refers to
    original="${!varname}"

    # effectfully accept the new variable's contents
    export "${@?}";

    # re-set $varname's variable to the contents of varname's
    # reference, plus the current (updated on the export) contents.
    # however, exclude the ${separator} unless ${original} starts
    # with a value
    eval "$varname=${!varname}${original:+${separator}${original}}"
}

function append() {
    varname=$1 # example: varname might contain the string "PATH"

    # drop off the varname
    shift

    separator=$1 # example: separator would usually be the string ":"
    # drop off the separator argument, so the remaining arguments
    # are the arguments to export
    shift


    # set $original to the contents of the the variable $varname
    # refers to
    original="${!varname:-}"

    # effectfully accept the new variable's contents
    export "${@?}";

    # re-set $varname's variable to the contents of varname's
    # reference, plus the current (updated on the export) contents.
    # however, exclude the ${separator} unless ${original} starts
    # with a value
    eval "$varname=${original:+${original}${separator}}${!varname}"
}

varmap() {
    if [ -f "$EVALUATION_ROOT/varmap-v1" ]; then
        # Capture the name of the variable being set
        IFS="=" read -r -a cur_varname <<< "$1"

        # With IFS='' and the `read` delimiter being '', we achieve
        # splitting on \0 bytes while also preserving leading
        # whitespace:
        #
        #    bash-3.2$ printf ' <- leading space\0bar\0baz\0' \
        #                  | (while IFS='' read -d $'\0' -r x; do echo ">$x<"; done)
        #    > <- leading space<
        #    >bar<
        #    >baz<```
        while IFS='' read -r -d '' map_instruction \
           && IFS='' read -r -d '' map_variable \
           && IFS='' read -r -d '' map_separator; do
            unset IFS

            if [ "$map_variable" == "${cur_varname[0]}" ]; then
                if [ "$map_instruction" == "append" ]; then
                    append "$map_variable" "$map_separator" "$@"
                    return
                fi
            fi
        done < "$EVALUATION_ROOT/varmap-v1"
    fi


    export "${@?}"
}

function declare() {
    if [ "$1" == "-x" ]; then shift; fi

    # Some variables require special handling.
    #
    # - punt:    don't set the variable at all
    # - prepend: take the new value, and put it before the current value.
    case "$1" in
        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L100
        "HOME="*) punt;;
        "USER="*) punt;;
        "LOGNAME="*) punt;;
        "DISPLAY="*) punt;;
        "PATH="*) prepend "PATH" ":" "$@";;
        "TERM="*) punt;;
        "IN_NIX_SHELL="*) punt;;
        "TZ="*) punt;;
        "PAGER="*) punt;;
        "NIX_BUILD_SHELL="*) punt;;
        "SHLVL="*) punt;;

        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L385
        "TEMPDIR="*) punt;;
        "TMPDIR="*) punt;;
        "TEMP="*) punt;;
        "TMP="*) punt;;

        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L421
        "NIX_ENFORCE_PURITY="*) punt;;

        # vars from: https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html (last checked: 2019-09-26)
        # reported in https://github.com/target/lorri/issues/153
        "OLDPWD="*) punt;;
        "PWD="*) punt;;
        "SHELL="*) punt;;

        # https://github.com/target/lorri/issues/97
        "preHook="*) punt;;
        "origPreHook="*) move "origPreHook" "preHook" "$@";;

        *) varmap "$@" ;;
    esac
}

export IN_NIX_SHELL=1

if [ -f "$EVALUATION_ROOT/bash-export" ]; then
    # shellcheck disable=SC1090
    . "$EVALUATION_ROOT/bash-export"
elif [ -f "$EVALUATION_ROOT" ]; then
    # shellcheck disable=SC1090
    . "$EVALUATION_ROOT"
fi

unset declare
