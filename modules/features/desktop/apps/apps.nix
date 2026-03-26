{
  config,
  lib,
  ...
}: let
  cfg = config.features.apps;
in {
  options.features.apps = {
    ghostty.enable = lib.mkEnableOption "ghostty terminal";
    yazi.enable = lib.mkEnableOption "yazi file manager";
    browser.enable = lib.mkEnableOption "browser";
    gtk.enable = lib.mkEnableOption "gtk theming";
    nh.enable = lib.mkEnableOption "nix helper (nh)";
    fastfetch.enable = lib.mkEnableOption "fastfetch system info";
  };

  config.flake.modules.homeManager.desktopApps = {...}: {
    imports = with config.flake.modules.homeManager;
      []
      ++ lib.optional cfg.ghostty.enable ghostty
      ++ lib.optional cfg.yazi.enable yazi
      ++ lib.optional cfg.browser.enable browser
      ++ lib.optional cfg.gtk.enable gtk
      ++ lib.optional cfg.nh.enable nh
      ++ lib.optional cfg.fastfetch.enable fastfetch;
  };
}
