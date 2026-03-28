{config, ...}: {
  flake.modules = {
    nixos.desktop = {...}: {
      imports = with config.flake.modules.nixos; [
        desktopServices
        compositors
        noctalia
      ];
    };

    homeManager.desktop = {...}: {
      imports = with config.flake.modules.homeManager; [
        apps
        compositors
        noctalia
        userServices
      ];
    };
  };
}
