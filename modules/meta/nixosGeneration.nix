{
  inputs,
  withSystem,
  config,
  lib,
  ...
}: let
  nixosModules = config.flake.modules.nixos;

  aspectsFor = layerModules: aspects:
    map (n: layerModules.${n}) (lib.filter (n: layerModules ? ${n}) aspects);
in {
  flake.nixosConfigurations =
    lib.mapAttrs (
      name: cfg: let
        host = config.registry.hosts.${name};
      in
        withSystem host.system (
          {...}:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {inherit inputs;};
              modules =
                [
                  cfg.module
                ]
                ++ (aspectsFor nixosModules host.aspects)
                ++ [
                  inputs.home-manager.nixosModules.home-manager
                  {
                    networking.hostName = name;
                    networking.hostId = lib.mkIf (host.hostId != "") host.hostId;
                    system.stateVersion = host.stateVersion;
                    nixpkgs.hostPlatform = host.system;
                    nixpkgs.config.allowUnfree = true;
                    home-manager.useGlobalPkgs = true;
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
    )
    config.configurations.nixos;
}
