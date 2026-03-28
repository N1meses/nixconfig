{ config, ... }: let
  flakeConfig = config;
in {
  flake.modules.homeManager.apps = {...}: {
    imports = with flakeConfig.flake.modules.homeManager; [
      ghostty
      yazi
      browser
      gtk
      nh
      fastfetch
    ];
  };
}
