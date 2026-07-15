{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  hosts = config.registry.hosts;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
  mkHomeModules = config.aspectLib.mkHomeModules;

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
      moduleSet = config.aspectLib.nixosModules;
      hmModule = inputs.home-manager.nixosModules.home-manager;
      output = "nixosConfigurations";
      select = host: host.nixosModule;
      mkSystem = {
        host,
        modules,
      }:
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
        };
    };

    finix = {
      moduleSet = config.aspectLib.finixModules or {};
      hmModule = inputs.community-modules.nixosModules.home-manager;
      output = "finixConfigurations";
      select = host: host.finixModule;
      mkSystem = {
        host,
        modules,
      }: let
        eval = inputs.nixpkgs.lib.evalModules {
          class = "finix";
          specialArgs = {
            inherit inputs;
            modules = inputs.finix.nixosModules;
          };
          modules =
            [inputs.finix.nixosModules.default]
            ++ modules
            ++ [
              {
                nixpkgs.pkgs = import inputs.nixpkgs {
                  inherit (host) system;
                  config.allowUnfree = true;
                  config.permittedInsecurePackages = ["pnpm-10.29.2"];
                  overlays = [
                    (_final: prev: {
                      home-manager = prev.home-manager.overrideAttrs (_: {
                        src =
                          inputs.home-manager;
                      });
                    })
                  ];
                };
              }
            ];
        };
      in
        eval // {inherit (eval._module.args) pkgs;};
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
            ++ aspectsFor cls.moduleSet (resolveAspects host.aspects)
            ++ [cls.hmModule (commonModule name host)];
        }
    ) (lib.filterAttrs (_: host: cls.select host != null) hosts);
in {
  nixosConfigurations = buildClass classes.nixos;
  finixConfigurations = buildClass classes.finix;
  homeConfigurations =
    lib.mapAttrs
    (_name: host:
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
      })
    (lib.filterAttrs (_: host: host.homeModule != null) hosts);
}
