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
      ];
    };

    homeManager.services = {...}: {
      imports = with flakeConfig.flake.modules.homeManager; [
        userServices
      ];
    };

    finix.services = {...}: {
      imports = with flakeConfig.flake.modules.finix; [
        fonts
        ly
        audio
        bluetooth
      ];
    };
  };
}
