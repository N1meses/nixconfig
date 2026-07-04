{config, ...}: {
  flake = {
    modules.homeManager.foot = {lib, ...}: {
      features.compositors.terminal = lib.mkDefault {
        command = "foot";
        execFlag = "";
        classFlag = "--app-id";
        appId = "foot";
      };

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "IBM Plex Mono:size=12";
            term = "foot";
          };
        };
      };
    };
    aspectInclude.foot = with config.flake.lib.aspects; [compositors];
  };
}
