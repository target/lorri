#!/bin/sh

# loaded by bash, never executed by bash
if [ "${LORRI_PROMPT_INIT:-0}" -eq 0 ]; then
    LORRI_PROMPT_INIT=1
    LORRI_PREV_ROOT=$(readlink "$LORRI_SHELL_ROOT")
    PS1="(lorri) $PS1"
fi

if [ "$(readlink "$LORRI_SHELL_ROOT")" != "$LORRI_PREV_ROOT" ]; then
    echo "lorri: Reloading"
    exec nix-shell "$LORRI_SHELL_ROOT"
fi
