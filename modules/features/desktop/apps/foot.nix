{...}: {
  flake.modules.homeManager.foot = {lib, ...}: {
    features.compositors.terminal = lib.mkDefault {
      command = "foot";
      execFlag = "";
      classFlag = "--app-id";
    };

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "IBM Plex Mono:size=12";
          term = "foot";
        };
        colors = {
          background = "201b14";
          foreground = "d4d4d4";
          regular0 = "0d0d0d";
          regular1 = "d16969";
          regular2 = "57A64A";
          regular3 = "DCDCAA";
          regular4 = "569cd6";
          regular5 = "BD63C5";
          regular6 = "4EC9B0";
          regular7 = "d4d4d4";
          bright0 = "7F7F7F";
          bright1 = "f48771";
          bright2 = "6A9955";
          bright3 = "e2c08d";
          bright4 = "9cdcfe";
          bright5 = "BD63C5";
          bright6 = "4EC9B0";
          bright7 = "ffffff";
        };
      };
    };
  };
}
