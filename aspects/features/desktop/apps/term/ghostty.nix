{ config, ... }: {
  aspects.desktop.apps.term.ghostty = {
    description = "The ghostty terminal emulator.";
    includes = with config.aspectLib.aspectNames; [ desktop.compositors.compositors ];
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
          theme = "noctalia-wallpaper";
          font-size = 12;
          font-family = "Monaspace Neon Frozen";
          term = "xterm-256color";
          confirm-close-surface = false;
        };
      };
    };
  };
}
