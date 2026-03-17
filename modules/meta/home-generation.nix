{ inputs, withSystem, config, lib, ... }: {
  flake.homeConfigurations = lib.mapAttrs (
    name: { module }:
      let host = config.registry.hosts.${name};
      in withSystem host.system ({ pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            module
            {
              home = {
                username = host.username;
                homeDirectory = host.homeDirectory;
                stateVersion = host.stateVersion;
              };
            }
          ];
        }
      )
  )
  config.configurations.home-manager;
}
