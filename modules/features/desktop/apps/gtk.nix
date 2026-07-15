_: {
  aspects.gtk.home = {pkgs, ...}: {
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

      iconTheme = {
        name = "Pop";
        package = pkgs.pop-icon-theme;
      };

      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.theme = null;
    };
  };
}
