_: {
  aspects.fonts.description = "System font packages and fontconfig.";
  aspects.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        ibm-plex
        google-fonts
        material-symbols
        nerd-fonts.symbols-only
      ];
    };

    finix = { pkgs, ... }: {
      fonts = {
        fontconfig.enable = true;
        packages = with pkgs; [
          ibm-plex
          google-fonts
          material-symbols
          nerd-fonts.symbols-only
          noto-fonts-color-emoji
          dejavu_fonts
          liberation_ttf
          unifont
        ];
      };
    };
  };
}
