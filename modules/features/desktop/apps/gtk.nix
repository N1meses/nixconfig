{...}: {
  flake.modules.homeManager.gtk = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.features.apps.gtk.enable = lib.mkEnableOption "gtk theming";

    config = lib.mkIf config.features.apps.gtk.enable {
      gtk = {
        enable = true;
        font = {
          name = "IBM Plex Sans";
          size = 10;
        };

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          extraCss = ''
            @import "${config.xdg.configHome}/gtk-3.0/colors.css";
          '';
        };

        gtk4.theme = config.gtk.theme;

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          extraCss = ''
            @import "${config.xdg.configHome}/gtk-4.0/colors.css";
          '';
        };
      };
    };
  };
}
