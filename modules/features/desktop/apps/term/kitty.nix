{ config, ... }: {
  aspects.kitty.description = "The kitty terminal emulator.";
  aspects.kitty.home = { lib, ... }: {
    features.compositors.autoStart = [ "kitty --single-instance" ];

    features.compositors.terminal = lib.mkDefault {
      command = "kitty";
      execFlag = "";
      classFlag = "--class";
      appId = "kitty";
      args = [ "--single-instance" ];
    };

    rum.programs.kitty = {
      enable = true;
      settings = {
        include = "~/.config/kitty/themes/noctalia.conf";
        font_family = "IBM Plex Mono";
        font_size = 12;
        term = "xterm-256color";
        confirm_os_window_close = 0;
        wheel_scroll_multiplier = "5.0";
        touch_scroll_multiplier = "3.0";
        symbol_map = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B1,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F532,U+F0001-U+F1AF0 Symbols Nerd Font Mono";
      };
    };
  };
  aspects.kitty.includes = with config.aspectLib.names; [ compositors ];
}
