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
                config.flake.modules.homeManager.compositors
                module
                {
                  nixpkgs.config.allowUnfree = true;
                  home = {
                    username = host.username;
                    homeDirectory = host.homeDirectory;
                    stateVersion = host.stateVersion;
                  };
                  programs.git.settings.user = {
                    name = host.gitName;
                    email = host.gitEmail;
                  };
                }
              ];
            }
        )
    )
    config.configurations.homeManager;
}
