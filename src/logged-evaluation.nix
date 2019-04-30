{ src, runTimeClosure }:
let
  runtimeCfg = import runTimeClosure;

  # using scopedImport, replace readDir and readFile with
  # implementations which will log files and paths they see.
  overrides = {
    import = scopedImport overrides;
    scopedImport = x: builtins.scopedImport (overrides // x);
    builtins = builtins // {
      readFile = file: builtins.trace "lorri read: '${toString file}'" (builtins.readFile file);
      readDir = path: builtins.trace "lorri read: '${toString path}'" (builtins.readDir path);
    };
  };

  imported =
    let
      raw = overrides.scopedImport overrides src;
    in if (builtins.isFunction raw)
    then raw {}
    else raw;

  trace_attribute_msg = name: value:
    "lorri attribute: '${name}' -> '${value.drvPath}'";

  # If you add a .drv to a gc-root, the `.drv` itself is protected
  # from GC, and the parent `drv`s up the tree are also protected.
  # However, the output paths referenced in any of the drvs are NOT
  # protected.
  #
  # The keep-env-hack function takes a given derivation and replaces
  # its builder with an `env` dumper.
  #
  # gc rooting the resulting store path from this build will retain
  # references to all the store paths needed, preventing the shell's
  # actual environment from being deleted.
  keep-env-hack = drv: derivation (drv.drvAttrs // {
    name = "lorri-keep-env-hack-${drv.name}";

    origExtraClosure = drv.extraClosure or [];
    extraClosure = runtimeCfg.closure;

    origBuilder = drv.builder;
    builder = runtimeCfg.builder;

    origSystem = drv.system;
    system = builtins.currentSystem;

    origPATH = drv.PATH or "";
    PATH = runtimeCfg.path;

    origArgs = drv.args or [];
    args = [ "-e" (builtins.toFile "lorri-keep-env-hack" ''
      # Export IN_NIX_SHELL to trick various Nix tooling to export
      # shell-friendly variables

      export IN_NIX_SHELL=1

      # https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#
      [ -e $stdenv/setup ] && . $stdenv/setup
      export > $out
    '') ];
  });

  trace_attribute = name: drv:
    builtins.trace (trace_attribute_msg name drv);


  gc-root = keep-env-hack imported;
in (trace_attribute "shell" imported)
   (trace_attribute "shell_gc_root" gc-root)
   gc-root
