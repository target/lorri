with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    shellHook = ''
      mkdir -p /tmp/foo/bar
      addToSearchPathWithCustomDelimiter : EXAMPLE /tmp/foo/bar
    '';
  };
}
