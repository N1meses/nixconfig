_: {
  flake.modules.homeManager.ghostty = {lib, ...}: {
    features.compositors.terminal = lib.mkDefault {
      command = "ghostty";
      execFlag = "-e";
      classFlag = "--class";
      appId = "com.mitchellh.ghostty";
    };

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "noctalia";
        font-size = 12;
        font-family = "IBM Plex Mono";
        term = "xterm-256color";
        confirm-close-surface = false;
      };
    };
  };
}
