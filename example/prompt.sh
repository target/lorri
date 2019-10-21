#! /usr/bin/env -S shellHook= nix-shell
#! nix-shell -i bash -p jq findutils libnotify

# As part of PS1 command, likely you don't want this output

shell_nix=${1:-${NIX_SHELL_PATH:?"Usage: $0 <path to shell.nix>"}}
shell_nix=$(realpath "$shell_nix")
complete_glyph=✔
building_glyph=⏳
failed_glyph=✘
unknown_glyph="¿"

glyph=$(lorri stream_events_ -k snapshot | jq -r \
  "(if .completed?.nix_file == \"$shell_nix\" then \"${complete_glyph}\" else null end),
   (if .failure?.nix_file == \"$shell_nix\" then  \"${failed_glyph}\" else null end),
   (if .started?.nix_file == \"$shell_nix\" then \"${building_glyph}\" else null end) | values")

if [ -z "$glyph" ]; then
  echo -n $unknown_glyph
  exit 1
fi

echo -n "$glyph"

if [ "$glyph" = "$failed_glyph" ]; then
  exit 1
fi

exit 0
