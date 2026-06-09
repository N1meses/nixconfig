{
  inputs,
  withSystem,
  config,
  lib,
  ...
}: let
  homeModules = config.flake.modules.homeManager;

  aspectsFor = layerModules: aspects:
    map (n: layerModules.${n}) (lib.filter (n: layerModules ? ${n}) aspects);
in {
  flake.homeConfigurations =
    lib.mapAttrs (
      name: {module}: let
        host = config.registry.hosts.${name};
      in
        withSystem host.system (
          {pkgs, ...}:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules =
                [
                  config.flake.modules.homeManager.compositors
                  module
                  {
                    nixpkgs.config.allowUnfree = true;
                  }
                ]
                ++ (aspectsFor homeModules host.aspects)
                ++ [
                  {
                    home = {
                      username = host.username;
                      homeDirectory = host.homeDirectory;
                      stateVersion = host.stateVersion;
                    };
                    programs.git = {
                      enable = true;
                      settings.user = {
                        name = host.gitName;
                        email = host.gitEmail;
                      };
                    };
                  }
                ];
            }
        )
    )
    config.configurations.homeManager;
}
