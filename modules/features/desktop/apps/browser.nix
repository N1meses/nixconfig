{
  config,
  lib,
  ...
}: let
  cfg = config.features.apps.browser;
in {
  flake.modules.homeManager.browser = {pkgs, ...}: let
    browserApp =
      if (cfg.defaultBrowser == "chromium")
      then "chromium-browser.desktop"
      else if (cfg.defaultBrowser == "firefox")
      then "firefox.desktop"
      else "brave-browser.desktop";
  in {
    home.packages = with pkgs;
      []
      ++ lib.optional ((cfg.defaultBrowser == "brave") || cfg.brave.enable) brave
      ++ lib.optional ((cfg.defaultBrowser == "firefox") || cfg.firefox.enable) firefox
      ++ lib.optional ((cfg.defaultBrowser == "chromium") || cfg.chromium.enable) chromium;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [browserApp];
        "x-scheme-handler/http" = [browserApp];
        "x-scheme-handler/https" = [browserApp];
        "x-scheme-handler/about" = [browserApp];
        "x-scheme-handler/unknown" = [browserApp];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
      };
      associations.added = {
        "text/html" = [browserApp];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
      };
    };
  };
}
