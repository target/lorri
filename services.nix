let
  pkgs = import <nixpkgs> {};
in
[
  { name = "http-server"; program = "${pkgs.python3}/bin/python3"; args = [ "-m" "http.server" ]; }
  { name = "notify"; program = "${pkgs.bash}/bin/bash"; args = [ "-c" "ls | ${pkgs.entr}/bin/entr -p echo \"file changed:\" /_" ]; }
]
