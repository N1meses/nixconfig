{
  inputs,
  withSystem,
  config,
  lib,
  ...
}: {
  flake.homeConfigurations =
    lib.mapAttrs (
      name: {module}: let
        host = config.registry.hosts.${name};
      in
        withSystem host.system (
          {pkgs, ...}:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                (config.flake.lib.mkHomeModules {
                  inherit host;
                  homeModule = module;
                })
                {nixpkgs.config.allowUnfree = true;}
              ];
            }
        )
    )
    config.configurations.homeManager;
}
