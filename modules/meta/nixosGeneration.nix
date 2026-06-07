{
  inputs,
  withSystem,
  config,
  lib,
  ...
}: {
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
                      lib.mkIf (homeConfig != null) {
                        imports = [config.flake.modules.homeManager.compositors homeConfig.module];
                        home = {
                          username = host.username;
                          homeDirectory = host.homeDirectory;
                          stateVersion = host.stateVersion;
                        };
                        programs.git.settings.user = {
                          name = host.gitName;
                          email = host.gitEmail;
                        };
                      };
                  }
                ];
            }
        )
    )
    config.configurations.nixos;
}
