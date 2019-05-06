with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    shellHook = ''
      GOPATH=$GOPATH:/bogus/bug-23/gopath
    '';
  };
}
