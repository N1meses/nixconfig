{config, ...}: {
    aspects.foot.home = {lib, ...}: {
      features.compositors.terminal = lib.mkDefault {
        command = "foot";
        execFlag = "";
        classFlag = "--app-id";
        appId = "foot";
      };

      rum.programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "IBM Plex Mono:size=12,Symbols Nerd Font Mono:size=12";
            term = "foot";
          };
        };
      };
    };
    aspects.foot.includes = with config.aspectLib.names; [compositors];
}
