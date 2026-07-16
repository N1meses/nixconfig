_: {
  aspects.gtk.home =
    {
      config,
      pkgs,
      ...
    }:
    let
      cursorName = "Nordzy-cursors";
      cursorSize = config.features.compositors.cursor.size;
    in
    {
      rum.misc.gtk = {
        packages = with pkgs; [
          adw-gtk3
          pop-icon-theme
          nordzy-cursor-theme
        ];
        settings = {
          theme-name = "adw-gtk3";
          icon-theme-name = "Pop";
          font-name = "IBM Plex Sans 10";
          cursor-theme-name = cursorName;
          cursor-theme-size = cursorSize;
          application-prefer-dark-theme = true;
        };
      };

      packages = [ pkgs.nordzy-cursor-theme ];
      environment.sessionVariables = {
        XCURSOR_THEME = cursorName;
        XCURSOR_SIZE = toString cursorSize;
      };
    };
}
