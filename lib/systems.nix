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

  commonOverlays = [
    inputs.halley.overlays.default
    inputs.umbriel.overlays.default
  ];

  classes = {
    nixos = {
      layer = "nixos";
      output = "nixosConfigurations";
      moduleSet = modulesFor.nixos;
      hmModule = inputs.hjem.nixosModules.default;
      mkSystem =
        {
          host,
          modules,
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = modules ++ [
            {
              nixpkgs = {
                hostPlatform = host.system;
                config.allowUnfree = true;
                config.permittedInsecurePackages = [
                  "pnpm-10.29.2"
                  "electron-40.10.5"
                ];
                overlays = commonOverlays;
              };
              system.stateVersion = host.stateVersion;
            }
          ];
        };
    };

    finix = {
      layer = "finix";
      output = "finixConfigurations";
      moduleSet = modulesFor.finix;
      hmModule = inputs.hjem.finixModules.default;
      mkSystem =
        {
          host,
          modules,
        }:
        let
          eval = inputs.nixpkgs.lib.evalModules {
            class = "nixos";
            specialArgs = {
              inherit inputs;
              modules = inputs.finix.nixosModules;
            };
            modules = [
              inputs.finix.nixosModules.default
            ]
            ++ modules
            ++ [
              {
                nixpkgs.pkgs = import inputs.nixpkgs {
                  inherit (host) system;
                  config.allowUnfree = true;
                  config.permittedInsecurePackages = [
                    "pnpm-10.29.2"
                    "minio-2025-10-15T17-29-55Z"
                  ];
                  overlays = commonOverlays;
                };
              }
            ];
          };
        in
        eval // { inherit (eval._module.args) pkgs; };
    };
  };
in
{
  aspectLib = {
    inherit
      classes
      commonOverlays
      fleetFor
      mkHomeModules
      commonModule
      hostModules
      hostsOfClass
      ;
  };
}
