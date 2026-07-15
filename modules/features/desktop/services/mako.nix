{config, ...}: {
  aspects.mako.home = {
    config,
    lib,
    pkgs,
    ...
  }: let
    c = config.features.compositors;
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
    toVal = v:
      if lib.isBool v
      then
        (
          if v
          then "1"
          else "0"
        )
      else toString v;
  in {
    packages = [pkgs.mako];
    xdg.config.files."mako/config".text =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${toVal v}") settings);
    # run as a compositor autostart (hjem has no user services)
    features.compositors.autoStart = ["mako"];
  };
  aspects.mako.includes = with config.aspectLib.names; [compositors];
}
