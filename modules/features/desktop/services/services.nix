{config, ...}: let
  flakeConfig = config;
in {
  flake.modules = {
    nixos.services = {...}: {
      imports = with flakeConfig.flake.modules.nixos; [
        graphics
        fonts
        portals
        audio
        bluetooth
        greetd
      ];
    };

    homeManager.services = {...}: {
      imports = with flakeConfig.flake.modules.homeManager; [
        userServices
      ];
    };
  };
}
