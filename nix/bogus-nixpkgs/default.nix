{ ... }:
let
  bogusFO = builder: name: derivation {
    inherit name;
    builder = builder;
    system = builtins.currentSystem;
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = builtins.hashString "sha256" name;
  };

  bogusUnstable = builder: name: derivation {
    inherit name;
    builder = builder;
    system = builtins.currentSystem;
    bust = builtins.currentTime;
  };

  bogusPackage = bogusFO ./builder.sh;
  bogusUnstablePackage = bogusUnstable ./builder.sh;

in {
  mkShell = { name ? "shell", buildInputs ? [], env ? {} }: derivation
    (env // {
      inherit name;
      builder = ./shell-builder.sh;
      system = builtins.currentSystem;
      stdenv = ./stdenv;
    });

  hello = bogusPackage "hello-1.0.0";

  hello-unstable = bogusUnstablePackage "hello-unstable-1.0.0";

  git = bogusPackage "git-1.0.0";
}
