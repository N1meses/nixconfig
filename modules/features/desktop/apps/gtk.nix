{...}: {
  flake.modules.homeManager.gtk = {
    config,
    pkgs,
    ...
  }: {
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

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        extraCss = ''
          @import "${config.xdg.configHome}/gtk-4.0/colors.css";
        '';
      };
    };
  };
}
