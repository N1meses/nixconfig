{
  lib,
  config,
  ...
}: let
  cfg = config.features.compositors;
in {
  options.features.compositors = {
    niri = {
      enable = lib.mkEnableOption "Niri compositor";
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package to use for the Niri compositor.";
      };
      extraBinds = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = {};
        description = "Extra binds to pass to Niri.";
      };
    };

    hyprland = {
      enable = lib.mkEnableOption "Hyprland compositor";
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package to use for the Hyprland compositor.";
      };
      extraBinds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra binds to pass to Hyprland.";
      };
    };

    xwaylandSatellitePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Packages to use for the Xwayland satellite.";
    };

    appearance = {
      gaps = lib.mkOption {
        type = lib.types.int;
        default = 8;
        description = "Gap size for the appearance settings. Can be zero for no gaps";
      };

      border = {
        enable = lib.mkEnableOption "Border settings";
        width = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Border width for the appearance settings.";
        };
      };

      radius = lib.mkOption {
        type = lib.types.int;
        default = 16;
        description = "Window corner radius for the appearance settings.";
      };

      opacity = {
        active = lib.mkOption {
          type = lib.types.float;
          default = 0.95;
          description = "Opacity for active windows.";
        };
        inactive = lib.mkOption {
          type = lib.types.float;
          default = 0.9;
          description = "Opacity for inactive windows.";
        };
      };
    };

    animations = {
      enable = lib.mkEnableOption "Animation settings";
    };

    focus = {
      followMouse = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to follow the mouse cursor when focusing windows.";
      };
      onActivate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to focus the window when it is activated.";
      };
    };

    cursor = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package providing the cursor theme.";
      };

      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Name of the cursor theme to use.";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Size of the cursor.";
      };

      hideWhileTyping = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to hide the cursor while typing.";
      };

      hideTimeout = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Timeout in seconds before the cursor is hidden.";
      };
    };

    input = {
      keyboard.layout = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard layout to use.";
      };

      mouse.enable = lib.mkEnableOption "Mouse input settings";

      touchpad = {
        enable = lib.mkEnableOption "Touchpad input settings";
        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable natural scrolling for the touchpad.";
        };
        tapToClick = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable tap-to-click for the touchpad.";
        };
        disableWhileTyping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to disable the touchpad while typing.";
        };
        scrollFactor = lib.mkOption {
          type = lib.types.float;
          default = 1.0;
          description = "Scroll factor for the touchpad.";
        };
      };
    };

    autoStart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Whether to automatically start the compositor on login.";
    };

    monitors = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "Enable this monitor";

              resolution = {
                width = lib.mkOption {
                  type = lib.types.int;
                  description = "Monitor width in pixels";
                  example = 2880;
                };

                height = lib.mkOption {
                  type = lib.types.int;
                  description = "Monitor height in pixels";
                  example = 1920;
                };
              };

              refreshRate = lib.mkOption {
                type = lib.types.float;
                description = "Monitor Refresh Rate in Hz";
                example = 120.0;
                default = 60.0;
              };

              scale = lib.mkOption {
                type = lib.types.float;
                description = "Display scaling factor";
                default = 1.0;
                example = 1.6;
              };

              position = {
                x = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "X position in the layout";
                };

                y = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "Y position in the layout";
                };
              };

              transform = lib.mkOption {
                type = lib.types.enum [
                  "0" # 0° - no rotation
                  "90" # 90° clockwise
                  "180" # 180°
                  "270" # 270° clockwise / 90° counter-clockwise
                  "flipped" # flipped horizontally
                  "flipped-90"
                  "flipped-180"
                  "flipped-270"
                ];
                default = "0";
                description = "Monitor rotation/transform";
              };

              vrr.enable = lib.mkEnableOption "Enable variable refresh rate";

              primary = lib.mkEnableOption "Enable this monitor as primary";
            };
          }
        )
      );
      default = null;
      example = {
        "eDP-1" = {
          resolution = {
            width = 2880;
            height = 1920;
          };
          transform = "0";
          scale = 1.6;
          vrr.enable = true;
          refreshRate = 120.0;
        };
      };
    };
  };

  config.flake.modules = {
    nixos.compositors = {lib, ...}: {
        assertions = [
          {
            assertion = (cfg.niri.enable || cfg.hyprland.enable) -> (cfg.monitors != null && builtins.attrNames cfg.monitors != []);
            message = ''
              You have to configure at least one monitor when enabling a compositor!

              Example:
                features.compositors.monitors."eDP-1" = {
                  resolution = { width = 2880; height = 1920; };
                  refreshRate = 120.0;
                  scale = 1.6;
                };
            '';
          }
        ];
        imports = with config.flake.modules.nixos;
          []
          ++ lib.optional cfg.niri.enable niri
          ++ lib.optional cfg.hyprland.enable hyprland;
      };
      homeManager.compositors = {pkgs, ...}: {
        imports = with config.flake.modules.homeManager;
          []
          ++ lib.optional cfg.niri.enable niri
          ++ lib.optional cfg.hyprland.enable hyprland;

        home.packages = with pkgs; [
          grim
          slurp
          wf-recorder
          swappy
          wayland-utils
          wl-clipboard
        ];

        services.wl-clip-persist.enable = true;
      };
  };
}
