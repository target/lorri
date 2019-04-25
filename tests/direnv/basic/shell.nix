with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    MARKER = "present";
    PATH = ./bin;
  };
}
