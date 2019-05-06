watch_file "$EVALUATION_ROOT"

function declare() {
    if [ "$1" == "-x" ]; then shift; fi

    function punt () {
        :
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
        eval original=\$$varname

        # effectfully accept the new variable's contents
        export "$@";

        # re-set $varname's variable to the contents of varname's
        # reference, plus the current (updated on the export) contents.
        eval $varname=\$$varname$separator$original
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
        eval original=\$$varname

        # effectfully accept the new variable's contents
        export "$@";

        # re-set $varname's variable to the contents of varname's
        # reference, plus the current (updated on the export) contents.
        eval $varname=$original$separator\$$varname
    }

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

        *)
            IFS="="
            varargs=($1)
            handled=0
            while read line; do
                 IFS=$'\t'
                 args=($line)
                 unset IFS

                 instruction=${args[0]}
                 variable=${args[1]}
                 separator=${args[2]}

                 if [ "$variable" == "${varargs[0]}" ]; then
                     if [ "$instruction" == "append" ]; then
                         append "$variable" "$separator" "$@"
                         handled=1
                         break
                     fi
                 fi
            done < "$EVALUATION_ROOT/varmap"
            if [ $handled -eq 0 ]; then
                export "$@"
            fi
            ;;
    esac
}

export IN_NIX_SHELL=1
. "$EVALUATION_ROOT/bash-export"

unset declare
