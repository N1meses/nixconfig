{...}: {
  flake.modules.homeManager.ghostty = {...}: {
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
}
