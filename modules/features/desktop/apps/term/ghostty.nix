{ config, ... }: {
  aspects.desktop.apps.term.ghostty = {
    description = "The ghostty terminal emulator.";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home = { lib, ... }: {
      features.compositors.terminal = lib.mkDefault {
        command = "ghostty";
        execFlag = "-e";
        classFlag = "--class";
        appId = "com.mitchellh.ghostty";
      };

      rum.programs.ghostty = {
        enable = true;
        settings = {
          theme = "noctalia";
          font-size = 12;
          font-family = "IBM Plex Mono";
          term = "xterm-256color";
          confirm-close-surface = false;
        };
      };
    };
  };
}
