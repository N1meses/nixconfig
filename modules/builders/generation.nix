{
  inputs,
  config,
  lib,
  ...
}:
let
  hosts = config.registry.hosts;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
  mkHomeModules = config.aspectLib.mkHomeModules;

  fleetFor =
    layer: self: map (f: f.${layer}) (builtins.attrValues (removeAttrs config.fleet [ self ]));

  systemAspectNames =
    host:
    resolveAspects (host.aspects ++ lib.concatMap (u: config.registry.users.${u}.aspects) host.users);

  commonModule =
    name: host:
    {
      networking.hostName = name;
      networking.hostId = lib.mkIf (host.hostId != "") host.hostId;
      hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
      hjem.clobberByDefault = true;
      hjem.users = lib.genAttrs host.users (uname: {
        enable = true;
        imports = [
          (mkHomeModules {
            inherit host;
            user = config.registry.users.${uname};
          })
        ]
        ++ fleetFor "home" name;
      });
    }
    // lib.optionalAttrs (host.domain != "") {
      features.server.domain = host.domain;
    };

  classes = {
    nixos = {
      moduleSet = config.aspectLib.nixosModules;
      hmModule = inputs.hjem.nixosModules.default;
      output = "nixosConfigurations";
      layer = "nixos";
      select = host: host.nixosModule;
      mkSystem =
        {
          host,
          modules,
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = modules ++ [
            {
              nixpkgs.hostPlatform = host.system;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.permittedInsecurePackages = [
                "pnpm-10.29.2"
                "electron-40.10.5"
              ];
              system.stateVersion = host.stateVersion;
            }
          ];
        };
    };

    finix = {
      moduleSet = config.aspectLib.finixModules or { };
      hmModule = inputs.hjem.finixModules.default;
      output = "finixConfigurations";
      layer = "finix";
      select = host: host.finixModule;
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
                };
              }
            ];
          };
        in
        eval // { inherit (eval._module.args) pkgs; };
    };
  };

  buildClass =
    cls:
    lib.mapAttrs (
      name: host:
      cls.mkSystem {
        inherit host;
        modules = [
          (cls.select host)
        ]
        ++ aspectsFor cls.moduleSet (systemAspectNames host)
        ++ [
          cls.hmModule
          (commonModule name host)
        ]
        ++ fleetFor cls.layer name;
      }
    ) (lib.filterAttrs (_: host: cls.select host != null) hosts);

  userFiles = user: [
    user.files
    user.xdg.cache.files
    user.xdg.config.files
    user.xdg.data.files
    user.xdg.state.files
  ];

  fileToJson =
    f:
    lib.filterAttrs (_: v: v != null) {
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
      files = map fileToJson (lib.filter (f: f.enable) (lib.concatMap lib.attrValues (userFiles user)));
    };
    inherit (user) packages;
  };

  mkStandaloneHost =
    c: lib.mapAttrs (_: mkStandaloneUser) (lib.filterAttrs (_: u: u.enable) c.config.hjem.users);

  nixos = buildClass classes.nixos;
  finix = buildClass classes.finix;
in
{
  nixosConfigurations = nixos;
  finixConfigurations = finix;
  homeConfigurations = lib.mapAttrs (_: mkStandaloneHost) (finix // nixos);
}
