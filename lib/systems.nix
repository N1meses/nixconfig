{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    optional
    optionals
    ;

  inherit (config.aspectLib)
    all
    aspectsFor
    modulesFor
    resolve
    usersOf
    ;

  fleetFor =
    layer: self:
    filter (m: m != null) (
      map (h: h.fleet.${layer}) (builtins.attrValues (removeAttrs config.hosts [ self ]))
    );

  mkHomeModules =
    hostName: host: userName:
    let
      user = all.${userName};
    in
    {
      _module.args.userEntry = user;

      imports =
        aspectsFor modulesFor.home (resolve [ userName ])
        ++ optional (host.home != null) host.home
        ++ fleetFor "home" hostName;

      rum.programs.git = {
        enable = true;
        settings.user = { inherit (user.git) name email; };
      };
    };

  commonModule = name: host: {
    networking.hostName = name;
    _module.args.hostName = name;
    _module.args.hostEntry = host;

    hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
    hjem.clobberByDefault = true;
    hjem.users = builtins.listToAttrs (
      map (u: {
        name = lib.removePrefix "users." u;
        value = {
          enable = true;
          imports = [ (mkHomeModules name host u) ];
        };
      }) (usersOf "hosts.${name}")
    );
  };

  hostModules =
    {
      name,
      host,
      cls,
      machine ? true,
      extra ? [ ],
    }:
    aspectsFor cls.moduleSet (resolve [ "hosts.${name}" ])
    ++ optionals machine host.machineModules
    ++ [
      cls.hmModule
      (commonModule name host)
    ]
    ++ fleetFor cls.layer name
    ++ extra;

  hostsOfClass = class: lib.filterAttrs (_: host: builtins.elem class host.classes) config.hosts;
in
{
  aspectLib = {
    inherit
      fleetFor
      mkHomeModules
      commonModule
      hostModules
      hostsOfClass
      ;
  };
}
