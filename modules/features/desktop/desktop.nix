{config, ...}: let
  flakeConfig = config;
in {
  flake.modules = {
    nixos.desktop = {...}: {
      imports = with flakeConfig.flake.modules.nixos; [
        services
      ];
    };

    homeManager.desktop = {...}: {
      imports = with flakeConfig.flake.modules.homeManager; [
        apps
        noctalia
        services
      ];
    };
  };
}
