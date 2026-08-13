{
  lib,
  config,
  ...
}:
let
  inherit (config.aspectLib) resolveAspects layersOf;

  resolveHost =
    name: host:
    let
      class = if host.nixosModule != null then "nixos" else "finix";

      userNames = lib.concatMap (u: config.registry.users.${u}.aspects) host.users;
      systemNames = resolveAspects (host.aspects ++ userNames);
      homeNames = resolveAspects userNames;

      hits =
        n:
        lib.optional (lib.elem class (layersOf n) && lib.elem n systemNames) class
        ++ lib.optional (lib.elem "home" (layersOf n) && lib.elem n homeNames) "home";
    in
    {
      inherit class;
      inherit (host) users;
      aspectCount = builtins.length systemNames;
      aspects = lib.genAttrs systemNames hits;
      inert = lib.filter (n: hits n == [ ]) systemNames;
      aggregators = lib.filter (n: layersOf n == [ ]) systemNames;
    };
in
{
  resolved = lib.mapAttrs resolveHost config.registry.hosts;
}
