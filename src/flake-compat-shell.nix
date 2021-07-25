{ system ? builtins.currentSystem }:

(builtins.getFlake (toString ./.)).devShell.${system}