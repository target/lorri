with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    lorriMockSetupHook = ''
      local tmp=$(mktemp -d)
      mkdir -p "$tmp/foo/bar"
      for i in $(seq 1 1001); do
        addToSearchPathWithCustomDelimiter : GOPATH "$tmp/foo/bar"
      done

      addToSearchPathWithCustomDelimiter : ITWORKED "$tmp/foo/bar"
      rmdir "$tmp/foo/bar" "$tmp/foo" "$tmp"
    '';
  };
}
