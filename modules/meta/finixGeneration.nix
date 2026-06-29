{
  inputs,
  config,
  lib,
  ...
}: let
  finixModules = config.flake.modules.finix;
  stripClass = m: args: removeAttrs (m args) ["_class"];

  aspectsFor = layerModules: aspects:
    map (n: stripClass layerModules.${n}) (lib.filter (n: layerModules ? ${n}) aspects);
in {
  flake.finixConfigurations =
    lib.mapAttrs (
      name: cfg: let
        host = config.registry.hosts.${name};
      in
        inputs.finix.lib.finixSystem {
          lib = inputs.nixpkgs.lib;
          specialArgs = {
            inherit inputs;
            modules = inputs.finix.nixosModules;
          };
          modules =
            [
              cfg.module
              {
                nixpkgs.pkgs = import inputs.nixpkgs {
                  inherit (host) system;
                  config.allowUnfree = true;
                  overlays = [
                    (_final: prev: {
                      home-manager = prev.home-manager.overrideAttrs (_: {
                        src = inputs.home-manager;
                      });
                    })
                  ];
                };
              }
            ]
            ++ (aspectsFor finixModules host.aspects)
            ++ [
              inputs.finix-community-modules.nixosModules.home-manager
              {
                networking.hostName = name;
                networking.hostId = lib.mkIf (host.hostId != "") host.hostId;
                home-manager.users.${host.username} = let
                  homeConfig = config.configurations.homeManager.${name} or null;
                in
                  lib.mkIf (homeConfig != null)
                  (config.flake.lib.mkHomeModules {
                    inherit host;
                    homeModule = homeConfig.module;
                  });
              }
            ];
        }
    )
    config.configurations.finix;
}
