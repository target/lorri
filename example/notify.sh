#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq findutils libnotify

lorri stream_events_ --kind live |\
  jq --unbuffered \
     '((.completed?|values|"Build complete in \(.nix_file)"),
     (.failure? |values|"Build failed in \(.nix_file)"))' |\
  tee /dev/stderr |\
  xargs -n 1 notify-send "Lorri Build"
