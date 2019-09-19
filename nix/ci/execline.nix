# TODO: upstream all of this into nixpkgs
{ pkgs }:
# execline is a small utility which can be used as a general-purpose
# way of executing a command from a script without requiring a full
# posix shell.
#
# Its syntax is also dead-simple, so we can generate execline scripts
# from a nix list of strings and escape everything correctly, no further
# caution required on the programmer’s side.
#
# The main function here is `writeExecline`, which works like the
# functions in `pkgs.writers`.
#
# Documentation for execline is at
# http://skarnet.org/software/execline/index.html
# or in `pkgs.execline.doc`.
let

  # wrapper for execlineb that doesn’t need the execline commands
  # in PATH to work (making them appear like “builtins”)
  # TODO: upstream into nixpkgs
  execlineb-with-builtins =
    let eldir = "${pkgs.execline}/bin";
    in pkgs.writeScriptBin "execlineb" ''
      #!${eldir}/execlineb -s0
      ${eldir}/define eldir ${eldir}
      ''${eldir}/importas oldpath PATH
      ''${eldir}/export PATH "''${eldir}:''${oldpath}"
      ''${eldir}/execlineb $@
    '';

  # replaces " and \ to \" and \\ respectively and quote with "
  # e.g.
  #   a"b\c -> "a\"b\\c"
  #   a\"bc -> "a\\\"bc"
  # TODO upsteam into nixpkgs
  escapeExeclineArg = arg:
    ''"${builtins.replaceStrings [ ''"'' ''\'' ] [ ''\"'' ''\\'' ] (toString arg)}"'';

  # Escapes an execline (list of execline strings) to be passed to execlineb
  # Give it a nested list of strings. Nested lists are interpolated as execline
  # blocks ({}).
  # Everything is quoted correctly.
  #
  # Example:
  #   escapeExecline [ "if" [ "somecommand" ] "true" ]
  #   == ''"if" { "somecommand" } "true"''
  escapeExecline = execlineList: pkgs.lib.concatStringsSep " "
    (let
      go = arg:
        if      builtins.isString arg then [(escapeExeclineArg arg)]
        else if pkgs.lib.isDerivation arg then [(escapeExeclineArg arg)]
        else if builtins.isList arg then [ "{" ] ++ builtins.concatMap go arg ++ [ "}" ]
        else abort "escapeExecline can only hande nested lists of strings, was ${pkgs.lib.generators.toPretty {} arg}";
     in builtins.concatMap go execlineList);

  # Write a list of execline argv parameters to an execline script.
  # Everything is escaped correctly.
  # TODO upstream into nixpkgs
  writeExeclineCommon = writer: name: { readNArgs ? 0 }: argList: writer name ''
    #!${execlineb-with-builtins}/bin/execlineb -s${toString readNArgs}
    export EXECLINE_STRICT 2
    ${escapeExecline argList}
  '';
  writeExecline = writeExeclineCommon pkgs.writeScript;
  writeExeclineBin = writeExeclineCommon pkgs.writeScriptBin;

in {
  inherit
    writeExecline writeExeclineBin;
}
