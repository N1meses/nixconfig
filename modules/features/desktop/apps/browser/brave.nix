{ config, ... }: {
  aspects.desktop.apps.browser.brave = {
    description = "The Brave browser.";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home =
      {
        pkgs,
        lib,
        ...
      }:
      {
        imports = [ ./_common.nix ];

        features.compositors.browser = lib.mkDefault {
          command = "brave";
          args = [ ];
          appId = "brave-browser";
          desktopFile = "brave-browser.desktop";
        };

        packages = [ pkgs.brave ];
      };
  };
}
