{
  inputs,
  withSystem,
  config,
  lib,
  ...
}: let
  hosts = config.registry.hosts;
  aspectsFor = config.flake.lib.aspectsFor;
  resolveAspects = config.flake.lib.resolveAspects;
  mkHomeModules = config.flake.lib.mkHomeModules;

  commonModule = name: host:
    {
      networking.hostName = name;
      networking.hostId = lib.mkIf (host.hostId != "") host.hostId;
      home-manager.users.${host.username} =
        lib.mkIf (host.homeModule != null)
        (mkHomeModules {
          inherit host;
          inherit (host) homeModule;
        });
    }
    // lib.optionalAttrs (host.domain != "") {
      features.server.domain = host.domain;
    };

  classes = {
    nixos = {
      moduleSet = config.flake.modules.nixos;
      transform = m: m;
      hmModule = inputs.home-manager.nixosModules.home-manager;
      output = "nixosConfigurations";
      select = host: host.nixosModule;
      mkSystem = {
        host,
        modules,
      }:
        withSystem host.system (_:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules =
              modules
              ++ [
                {
                  nixpkgs.hostPlatform = host.system;
                  nixpkgs.config.allowUnfree = true;
                  nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2"];
                  system.stateVersion = host.stateVersion;
                  home-manager.useGlobalPkgs = true;
                }
              ];
          });
    };

    finix = {
      moduleSet = config.flake.modules.finix or {};
      transform = m: args: removeAttrs (m args) ["_class"];
      hmModule = inputs.finix-community-modules.nixosModules.home-manager;
      output = "finixConfigurations";
      select = host: host.finixModule;
      mkSystem = {
        host,
        modules,
      }:
        inputs.finix.lib.finixSystem {
          lib = inputs.nixpkgs.lib;
          specialArgs = {
            inherit inputs;
            modules = inputs.finix.nixosModules;
          };
          modules =
            modules
            ++ [
              {
                nixpkgs.pkgs = import inputs.nixpkgs {
                  inherit (host) system;
                  config.allowUnfree = true;
                  overlays = [
                    (_final: prev: {
                      home-manager = prev.home-manager.overrideAttrs (_: {src = inputs.home-manager;});
                    })
                  ];
                };
              }
            ];
        };
    };
  };

  buildClass = cls:
    lib.mapAttrs (
      name: host:
        cls.mkSystem {
          inherit host;
          modules =
            [
              (cls.select host)
            ]
            ++ map cls.transform (aspectsFor cls.moduleSet (resolveAspects host.aspects))
            ++ [cls.hmModule (commonModule name host)];
        }
    ) (lib.filterAttrs (_: host: cls.select host != null) hosts);
  bothSet = lib.filter (n: hosts.${n}.nixosModule != null && hosts.${n}.finixModule != null) (lib.attrNames hosts);
in {
  flake = lib.mkMerge (
    (lib.mapAttrsToList (_: cls: {${cls.output} = buildClass cls;}) classes)
    ++ lib.optional (bothSet != [])
    (throw "hosts set both nixosModule and finixModule (a host is one system class): ${toString bothSet}")
    ++ [
      {
        homeConfigurations =
          lib.mapAttrs
          (_name: host:
            withSystem host.system ({pkgs, ...}:
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  (mkHomeModules {
                    inherit host;
                    inherit (host) homeModule;
                  })
                  {
                    nixpkgs.config.allowUnfree = true;
                    nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2"];
                  }
                ];
              }))
          (lib.filterAttrs (_: host: host.homeModule != null) hosts);
      }
    ]
  );
}
