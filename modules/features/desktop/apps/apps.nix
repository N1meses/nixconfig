{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.homeManager.apps = {...}: {
    imports = with flakeConfig.flake.modules.homeManager; [
      yazi
      browser
      gtk
      nh
      fastfetch
    ];
  };
}
