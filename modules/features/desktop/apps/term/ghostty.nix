{ config, ... }: {
  aspects.ghostty.description = "The ghostty terminal emulator.";
  aspects.ghostty.home = { lib, ... }: {
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
  aspects.ghostty.includes = with config.aspectLib.names; [ compositors ];
}
