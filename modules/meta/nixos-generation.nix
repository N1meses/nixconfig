{ inputs, withSystem, config, lib, ... }: {
  flake.nixosConfigurations = lib.mapAttrs (
    name: cfg:
      let host = config.registry.hosts.${name};
      in withSystem host.system ({ pkgs, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            cfg.module
          ] ++ lib.optional (cfg.hardwareConfig != null) cfg.hardwareConfig
          ++ [
            inputs.home-manager.nixosModules.home-manager
            {
              networking.hostName = name;
              system.stateVersion = host.stateVersion;
              nixpkgs.hostPlatform = host.system;
              home-manager.users.${host.username} =
                let homeConfig = config.configurations.home-manager.${name} or null;
                in lib.mkIf (homeConfig != null) {
                  imports = [ homeConfig.module ];
                  home = {
                    username = host.username;
                    homeDirectory = host.homeDirectory;
                    stateVersion = host.stateVersion;
                  };
                };
            }
          ];
        }
      )
  )
  config.configurations.nixos;
}
