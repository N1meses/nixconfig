_: {
  flake.modules = {
    nixos.fonts = {pkgs, ...}: {
      fonts.packages = with pkgs; [
        ibm-plex
        google-fonts
        material-symbols
        nerd-fonts.symbols-only
      ];
    };

    finix.fonts = {pkgs, ...}: {
      fonts = {
        fontconfig.enable = true;
        packages = with pkgs; [
          ibm-plex
          google-fonts
          material-symbols
          nerd-fonts.symbols-only
        ];
      };
    };
  };
}
