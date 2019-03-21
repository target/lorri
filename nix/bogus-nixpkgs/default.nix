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

  bogusPackage = bogusFO ./builder.sh;

in {
  mkShell = { buildInputs }:
    bogusFO ./shell-builder.sh "shell";

  hello = bogusPackage "hello-1.0.0";

  git = bogusPackage "git-1.0.0";
}
