with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    shellHook = ''
      export GOPATH=$GOPATH:/bogus/bug-23/gopath
    '';
  };
}
