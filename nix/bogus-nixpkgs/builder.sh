#!/bin/sh

# only use built-ins!
printf "%s" "${name:?}" > "${out:?}"
