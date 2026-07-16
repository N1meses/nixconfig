{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  hosts = config.registry.hosts;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
  mkHomeModules = config.aspectLib.mkHomeModules;

  fleetFor =
    layer: self: map (f: f.${layer}) (builtins.attrValues (builtins.removeAttrs config.fleet [ self ]));

  commonModule =
    name: host:
    {
      networking.hostName = name;
      networking.hostId = lib.mkIf (host.hostId != "") host.hostId;
      hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
      hjem.users.${host.username} = lib.mkIf (host.homeModule != null) {
        enable = true;
        imports = [
          (mkHomeModules {
            inherit host;
            inherit (host) homeModule;
          })
        ]
        ++ fleetFor "home" name;
      };
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
                  config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
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
        ++ aspectsFor cls.moduleSet (resolveAspects host.aspects)
        ++ [
          cls.hmModule
          (commonModule name host)
        ]
        ++ fleetFor cls.layer name;
      }
    ) (lib.filterAttrs (_: host: cls.select host != null) hosts);
in
{
  nixosConfigurations = buildClass classes.nixos;
  finixConfigurations = buildClass classes.finix;
}
