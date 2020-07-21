{ pkgs }:

manpage:

pkgs.writers.writeDash "mandoc-lint" ''
  set -e
  lint_warnings="$(
    ${pkgs.mandoc}/bin/mandoc -Tlint < ${pkgs.lib.escapeShellArg manpage} \
      | ${pkgs.gnused}/bin/sed -e '/referenced manual not found/d'
  )"

  # only succeed if there were no warnings
  if [ ! -z "$lint_warnings" ]; then
    echo "$lint_warnings" >&2
    exit 1
  fi
''
