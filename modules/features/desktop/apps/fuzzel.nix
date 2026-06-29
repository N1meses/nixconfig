_: {
  flake.modules.homeManager.fuzzel = {
    lib,
    config,
    ...
  }: let
    c = config.features.compositors;
    toFuzzel = hex: "${lib.removePrefix "#" hex}ff";
  in {
    features.compositors.launcher.command = lib.mkDefault "fuzzel";

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${c.terminal.command}${lib.optionalString (c.terminal.execFlag != "") " ${c.terminal.execFlag}"}";
          font = "IBM Plex Mono:size=12";
          prompt = "» ";
          width = 40;
          lines = 10;
          horizontal-pad = 16;
          vertical-pad = 8;
          inner-pad = 0;
          line-height = 22;
          letter-spacing = 0;
        };
        colors = {
          background = toFuzzel c.colors.background;
          text = "d4d4d4ff";
          match = toFuzzel c.colors.active;
          selection = "${lib.removePrefix "#" c.colors.active}33";
          selection-text = "ffffffff";
          selection-match = toFuzzel c.colors.active;
          border = toFuzzel c.colors.active;
        };
        border = {
          width = c.borders.width;
          radius = c.borders.radius;
        };
      };
    };
  };
}
