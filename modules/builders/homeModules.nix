{config, ...}: let
  homeModules = config.aspectLib.homeModules;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
in {
  aspectLib.mkHomeModules = {
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
