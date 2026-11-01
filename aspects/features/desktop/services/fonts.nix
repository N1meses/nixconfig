_: {
  aspects.desktop.services.fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        (ibm-plex.override { families = [ "sans" ]; })
        monaspace.frozen
        nerd-fonts.symbols-only
      ];
    };

    finix = { pkgs, ... }: {
      fonts = {
        fontconfig.enable = true;
        packages = with pkgs; [
          (ibm-plex.override { families = [ "sans" ]; })
          monaspace.frozen
          nerd-fonts.symbols-only
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          dejavu_fonts
          liberation_ttf
          unifont
        ];
      };
    };
    description = "System font packages and fontconfig.";
  };
}
