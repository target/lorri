with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    lorriMockSetupHook = ''
      mkdir -p /tmp/foo/bar
      addToSearchPathWithCustomDelimiter : GOPATH /tmp/foo/bar
    '';
  };
}
