with import ../../../nix/bogus-nixpkgs {};
mkShell {
  env = {
    MY_ENV_VAR = "my_env_value";
  };
}
