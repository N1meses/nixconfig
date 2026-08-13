{
  lib,
  config,
  ...
}:
let
  inherit (config.aspectLib) resolveAspects layersOf;

  layersForClass = class: [ class ] ++ [ "home" ];

  resolveHost =
    name: host:
    let
      class = if host.nixosModule != null then "nixos" else "finix";
      live = layersForClass class;
      names = resolveAspects (
        host.aspects ++ lib.concatMap (u: config.registry.users.${u}.aspects) host.users
      );
      hits = n: lib.filter (l: lib.elem l live) (layersOf n);
    in
    {
      inherit class;
      inherit (host) users;
      aspectCount = builtins.length names;
      aspects = lib.genAttrs names hits;
      inert = lib.filter (n: hits n == [ ]) names;
      aggregators = lib.filter (n: layersOf n == [ ]) names;
    };
in
{
  resolved = lib.mapAttrs resolveHost config.registry.hosts;
}
