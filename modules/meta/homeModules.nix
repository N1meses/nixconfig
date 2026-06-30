{config, ...}: let
  homeModules = config.flake.modules.homeManager;
  aspectsFor = config.flake.lib.aspectsFor;
  resolveAspects = config.flake.lib.resolveAspects;
in {
  flake.lib.mkHomeModules = {
    host,
    homeModule,
  }: {
    imports =
      [
        homeModule
      ]
      ++ (aspectsFor homeModules (resolveAspects host.aspects));

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
