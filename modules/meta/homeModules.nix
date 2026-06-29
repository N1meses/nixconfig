{
  lib,
  config,
  ...
}: let
  homeModules = config.flake.modules.homeManager;
  aspectsFor = aspects:
    map (n: homeModules.${n}) (lib.filter (n: homeModules ? ${n}) aspects);
in {
  flake.lib.mkHomeModules = {
    host,
    homeModule,
  }: {
    imports =
      [
        homeModules.compositors
        homeModule
      ]
      ++ (aspectsFor host.aspects);

    home = {
      inherit (host) username;
      inherit (host) homeDirectory;
      inherit (host) stateVersion;
    };

    programs.git = {
      enable = true;
      settings.user = {
        name = host.git.name;
        email = host.git.email;
      };
    };
  };
}
