{...}: {
  flake.modules.homeManager.compositors = {
    lib,
    pkgs,
    ...
  }: {
    options.features.compositors = {
      monitors = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.attrsOf (
            lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "this monitor";
                resolution = {
                  width = lib.mkOption {
                    type = lib.types.int;
                    example = 2880;
                  };
                  height = lib.mkOption {
                    type = lib.types.int;
                    example = 1920;
                  };
                };
                refreshRate = lib.mkOption {
                  type = lib.types.float;
                  default = 60.0;
                };
                scale = lib.mkOption {
                  type = lib.types.float;
                  default = 1.0;
                };
                position = {
                  x = lib.mkOption {
                    type = lib.types.int;
                    default = 0;
                  };
                  y = lib.mkOption {
                    type = lib.types.int;
                    default = 0;
                  };
                };
                transform = lib.mkOption {
                  type = lib.types.enum ["0" "90" "180" "270" "flipped" "flipped-90" "flipped-180" "flipped-270"];
                  default = "0";
                };
                vrr.enable = lib.mkEnableOption "variable refresh rate";
                primary = lib.mkEnableOption "this monitor as primary";
              };
            }
          )
        );
        default = null;
      };

      terminal = {
        command = lib.mkOption {
          type = lib.types.str;
          default = "ghostty";
        };
        execFlag = lib.mkOption {
          type = lib.types.str;
          default = "-e";
          description = "Flag to exec a command in the terminal, empty string if not needed (e.g. foot).";
        };
        classFlag = lib.mkOption {
          type = lib.types.str;
          default = "--class";
          description = "Flag to set window class / app-id.";
        };
      };

      colors = {
        active = lib.mkOption {
          type = lib.types.str;
          default = "#50C878";
        };
        inactive = lib.mkOption {
          type = lib.types.str;
          default = "#595959";
        };
        background = lib.mkOption {
          type = lib.types.str;
          default = "#201b14";
        };
      };

      borders = {
        width = lib.mkOption {
          type = lib.types.int;
          default = 2;
        };
        radius = lib.mkOption {
          type = lib.types.number;
          default = 16;
        };
      };

      opacity = {
        focused = lib.mkOption {
          type = lib.types.float;
          default = 0.9;
        };
        unfocused = lib.mkOption {
          type = lib.types.float;
          default = 0.9;
        };
      };

      gaps = {
        inner = lib.mkOption {
          type = lib.types.int;
          default = 8;
        };
        outer = lib.mkOption {
          type = lib.types.int;
          default = 8;
        };
      };

      cursor = {
        size = lib.mkOption {
          type = lib.types.int;
          default = 24;
        };
      };

      keyboard = {
        layout = lib.mkOption {
          type = lib.types.str;
          default = "de";
        };
      };

      launcher = {
        command = lib.mkOption {
          type = lib.types.str;
          default = "fuzzel";
        };
      };
    };

    config = {
      home.packages = with pkgs; [
        wayland-utils
        wl-clipboard
      ];

      services.wl-clip-persist.enable = true;
    };
  };
}
