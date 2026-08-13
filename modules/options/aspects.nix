{ lib, config, ... }:
let
  t = lib.types;
  names = builtins.attrNames config.aspects;
in
{
  options = {
    aspects = lib.mkOption {
      default = { };
      type = t.attrsOf (
        t.submodule {
          options = {
            description = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = ''
                One line saying what selecting this aspect gets you. Consumed by the
                generated module reference, so prose lives next to the code it
                describes and cannot drift away from it.
              '';
            };
            includes = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
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
        }
      );
    };
    aspectLib = lib.mkOption {
      type = t.lazyAttrsOf t.raw;
      default = { };
    };
  };
  config.aspectLib =
    let
      layerSet =
        layer: lib.mapAttrs (_: a: a.${layer}) (lib.filterAttrs (_: a: a.${layer} != null) config.aspects);
    in
    {
      names = lib.genAttrs names (n: n);
      nixosModules = layerSet "nixos";
      homeModules = layerSet "home";
      finixModules = layerSet "finix";
      layers = [
        "nixos"
        "finix"
        "home"
      ];
      layersOf = n: lib.filter (l: config.aspects.${n}.${l} != null) config.aspectLib.layers;
      aspectsFor = layerModules: ns: map (n: layerModules.${n}) (lib.filter (n: layerModules ? ${n}) ns);
      resolveAspects =
        roots:
        map (e: e.key) (
          builtins.genericClosure {
            startSet = map (n: { key = n; }) roots;
            operator = { key, ... }: map (dep: { key = dep; }) (config.aspects.${key}.includes or [ ]);
          }
        );
    };
}
