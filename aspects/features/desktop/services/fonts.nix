_: {
  aspects.desktop.services.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        ibm-plex
        material-symbols
        nerd-fonts.symbols-only
      ];
    };

    finix = { pkgs, ... }: {
      fonts = {
        fontconfig.enable = true;
        packages = with pkgs; [
          ibm-plex
          material-symbols
          nerd-fonts.symbols-only
          noto-fonts-color-emoji
          dejavu_fonts
          liberation_ttf
          unifont
        ];
      };
    };
    description = "System font packages and fontconfig.";
  };
}
