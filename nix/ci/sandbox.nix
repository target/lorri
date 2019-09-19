{ pkgs, LORRI_ROOT, writeExecline }:

let

  # remove everything but a few selected environment variables
  runInEmptyEnv = additionalVars:
    let
        baseVars = [ "USER" "HOME" "TERM" ];
        keepVars = baseVars ++ additionalVars;
        importas = pkgs.lib.concatMap (var: [ "importas" var var ]) keepVars;
        # we have to explicitely call export here, because PATH is probably empty
        export = pkgs.lib.concatMap (var: [ "${pkgs.execline}/bin/export" var ''''${${var}}'' ]) keepVars;
    in writeExecline "empty-env" {}
         (importas ++ [ "emptyenv" ] ++ export ++ [ "${pkgs.execline}/bin/exec" "$@" ]);

in {
  inherit runInEmptyEnv;
}
