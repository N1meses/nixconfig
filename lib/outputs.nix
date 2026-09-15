{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    concatMap
    filter
    filterAttrs
    mapAttrs
    ;

  inherit (config.aspectLib)
    classes
    hostModules
    hostsOfClass
    ;

  buildClass =
    className: cls:
    mapAttrs (
      name: host:
      cls.mkSystem {
        inherit host;
        modules = hostModules { inherit name host cls; };
      }
    ) (hostsOfClass className);

  built = mapAttrs buildClass classes;

  userFiles = user: [
    user.files
    user.xdg.cache.files
    user.xdg.config.files
    user.xdg.data.files
    user.xdg.state.files
  ];

  fileToJson =
    f:
    filterAttrs (_: v: v != null) {
      inherit (f)
        clobber
        gid
        permissions
        source
        target
        type
        uid
        ;
    };

  mkStandaloneUser = user: {
    manifest = {
      version = 3;
      files = map fileToJson (filter (f: f.enable) (concatMap attrValues (userFiles user)));
    };
    inherit (user) packages;
  };

  mkStandaloneHost =
    c: mapAttrs (_: mkStandaloneUser) (filterAttrs (_: u: u.enable) c.config.hjem.users);

  primaryClass = host: builtins.head host.classes;

  homeConfigurations = mapAttrs (
    name: host: mkStandaloneHost built.${primaryClass host}.${name}
  ) config.hosts;

  diskoConfigurations = mapAttrs (_: host: host.disko) (
    filterAttrs (_: host: host.disko != null) config.hosts
  );
in
{
  nixosConfigurations = built.nixos;
  finixConfigurations = built.finix;
  inherit homeConfigurations diskoConfigurations;
}
