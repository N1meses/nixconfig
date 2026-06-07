{...}: {
  flake.modules.homeManager.mako = {
    lib,
    config,
    ...
  }: let
    c = config.features.compositors;
  in {
    services.mako = {
      enable = true;
      settings = {
        background-color = "${c.colors.background}ee";
        text-color = "#d4d4d4";
        border-color = c.colors.active;
        border-size = c.borders.width;
        border-radius = c.borders.radius;
        font = "IBM Plex Mono 11";
        width = 360;
        height = 120;
        margin = "8";
        padding = "12";
        default-timeout = 5000;
        layer = "overlay";
        anchor = "top-right";
        icons = true;
        max-icon-size = 48;
      };
    };
  };
}
