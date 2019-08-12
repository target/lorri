with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    preHook = "echo 'foo bar'";
  };
}
