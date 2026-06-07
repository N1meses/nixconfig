{...}: {
  flake.modules.homeManager.browser = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.features.apps.browser;
    desktopFile =
      {
        brave = "brave-browser.desktop";
        firefox = "firefox.desktop";
        chromium = "chromium-browser.desktop";
      }.${
        cfg.defaultBrowser
      };
  in {
    options.features.apps.browser.defaultBrowser = lib.mkOption {
      type = lib.types.enum ["brave" "firefox" "chromium"];
      default = "brave";
      description = "Default browser for mimeApps.";
    };

    config = {
      home.packages = [pkgs.brave];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [desktopFile];
          "x-scheme-handler/http" = [desktopFile];
          "x-scheme-handler/https" = [desktopFile];
          "x-scheme-handler/about" = [desktopFile];
          "x-scheme-handler/unknown" = [desktopFile];
          "application/pdf" = ["org.pwmt.zathura.desktop"];
        };
        associations.added = {
          "text/html" = [desktopFile];
          "application/pdf" = ["org.pwmt.zathura.desktop"];
        };
      };
    };
  };
}
