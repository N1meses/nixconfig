{...}: {
  flake.modules.homeManager.ghostty = {config, lib, ...}: {
    options.features.apps.ghostty.enable = lib.mkEnableOption "ghostty terminal";

    config = lib.mkIf config.features.apps.ghostty.enable {
      programs.ghostty = {
        enable = true;
        settings = {
          theme = "noctalia";
          font-size = 12;
          font-family = "IBM Plex Mono";
          term = "xterm-256color";
        };
      };
    };
  };
}
