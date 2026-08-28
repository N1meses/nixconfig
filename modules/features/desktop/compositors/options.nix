_: {
  aspects.desktop.compositors.compositors = {
    description = "Shared option surface every compositor implements: keybinds, monitors, autostart, terminal and launcher.";
    home =
      {
        lib,
        pkgs,
        ...
      }:
      {
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
                      type = lib.types.enum [
                        "0"
                        "90"
                        "180"
                        "270"
                        "flipped"
                        "flipped-90"
                        "flipped-180"
                        "flipped-270"
                      ];
                      default = "0";
                    };
                    vrr.enable = lib.mkEnableOption "variable refresh rate";
                    hdr = lib.mkOption {
                      type = lib.types.enum [
                        "off"
                        "on"
                        "auto"
                        "fullscreen"
                      ];
                      default = "off";
                      description = ''
                        HDR policy. `auto` engages only for a fullscreen surface
                        carrying HDR metadata, `fullscreen` for any fullscreen
                        surface, `on` keeps the output in PQ/BT.2020 always.
                      '';
                    };
                    sdrWhite = lib.mkOption {
                      type = lib.types.float;
                      default = 203.0;
                      description = "SDR reference white in cd/m², 80-1000. Only applies while hdr is active.";
                    };
                    tearing = lib.mkEnableOption ''
                      asynchronous page flips on this monitor. A safety gate only:
                      the compositor still tears just for a fullscreen window that
                      requests it through the tearing-control protocol, or that a
                      window rule opts in
                    '';
                    directScanout = lib.mkOption {
                      type = lib.types.bool;
                      default = true;
                      description = "Let eligible fullscreen buffers bypass composition. Turn off to work around scanout artifacts.";
                    };
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
            appId = lib.mkOption {
              type = lib.types.str;
              default = "com.mitchellh.ghostty";
              description = "Window class / app-id used in compositor window rules.";
            };
            args = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Extra arguments passed to the terminal on every invocation.";
            };
          };

          browser = {
            command = lib.mkOption {
              type = lib.types.str;
              default = "glide";
            };
            appId = lib.mkOption {
              type = lib.types.str;
              default = "glide";
              description = "Window class / app-id used in compositor window rules.";
            };
            desktopFile = lib.mkOption {
              type = lib.types.str;
              default = "glide.desktop";
              description = "Desktop entry id used for the mimeapps default handler.";
            };
            args = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Extra arguments passed to the browser on every invocation.";
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

          autoStart = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Commands to autostart with any active compositor.";
          };
        };

        config = {
          packages = with pkgs; [
            wayland-utils
            wl-clipboard
          ];
        };
      };
  };
}
