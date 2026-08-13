{ lib, config, ... }:
let
  t = lib.types;

  aspectType = t.submodule {
    freeformType = t.lazyAttrsOf aspectType;
    options = {
      description = lib.mkOption {
        type = t.nullOr t.str;
        default = null;
        description = ''
          One line saying what selecting this aspect gets you. Consumed by the
          generated module reference, so prose lives next to the code it
          describes and cannot drift away from it.

          It is also what marks a node as a real aspect rather than a namespace:
          `desktop` is only a path segment, `desktop.compositors.niri` is a thing
          you can select.
        '';
      };
      includes = lib.mkOption {
        type = t.listOf t.str;
        default = [ ];
        description = "Dotted names of aspects this one pulls in, transitively.";
      };
      nixos = lib.mkOption {
        type = t.nullOr t.deferredModule;
        default = null;
      };
      home = lib.mkOption {
        type = t.nullOr t.deferredModule;
        default = null;
      };
      finix = lib.mkOption {
        type = t.nullOr t.deferredModule;
        default = null;
      };
    };
  };

  slotNames = [
    "description"
    "includes"
    "nixos"
    "home"
    "finix"
  ];

  isAspect =
    node:
    node.description != null
    || node.includes != [ ]
    || node.nixos != null
    || node.home != null
    || node.finix != null;

  flattenFrom =
    prefix: node:
    lib.optionalAttrs (isAspect node) { ${prefix} = node; }
    // lib.concatMapAttrs (k: v: flattenFrom "${prefix}.${k}" v) (removeAttrs node slotNames);

  flat = lib.concatMapAttrs (k: v: flattenFrom k v) config.aspects;
  flatNames = builtins.attrNames flat;
in
{
  options = {
    aspects = lib.mkOption {
      default = { };
      type = t.lazyAttrsOf aspectType;
    };
    aspectLib = lib.mkOption {
      type = t.lazyAttrsOf t.raw;
      default = { };
    };
  };

  config.aspectLib =
    let
      layerSet = layer: lib.mapAttrs (_: a: a.${layer}) (lib.filterAttrs (_: a: a.${layer} != null) flat);
    in
    {
      all = flat;
      inherit flatNames;

      names = lib.foldl' (
        acc: n: lib.recursiveUpdate acc (lib.setAttrByPath (lib.splitString "." n) n)
      ) { } flatNames;

      nixosModules = layerSet "nixos";
      homeModules = layerSet "home";
      finixModules = layerSet "finix";

      layers = [
        "nixos"
        "finix"
        "home"
      ];
      layersOf = n: lib.filter (l: flat.${n}.${l} != null) config.aspectLib.layers;

      aspectsFor = layerModules: ns: map (n: layerModules.${n}) (lib.filter (n: layerModules ? ${n}) ns);

      resolveAspects =
        roots:
        let
          # Host/user `aspects` lists are enum-typed and bare words under
          # `with aspectLib.names` fail at eval, but `includes` is listOf str: a
          # quoted name that matches nothing used to enter the closure and then get
          # dropped without a word by aspectsFor. Fail loudly instead.
          includesOf =
            key:
            if flat ? ${key} then
              flat.${key}.includes
            else
              throw "unknown aspect \"${key}\" referenced from an includes list — it matches no entry in config.aspects";
        in
        map (e: e.key) (
          builtins.genericClosure {
            startSet = map (n: { key = n; }) roots;
            operator = { key, ... }: map (dep: { key = dep; }) (includesOf key);
          }
        );
    };
}
