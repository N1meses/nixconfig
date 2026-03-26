{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.features.compositors;

  mouseBinds = {
    "Mod+WheelScrollDown".action.focus-column-right = [];
    "Mod+WheelScrollUp".action.focus-column-left = [];

    "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = [];
    "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = [];

    "Mod+Shift+WheelScrollDown".action.move-column-right = [];
    "Mod+Shift+WheelScrollUp".action.move-column-left = [];
    "Mod+MouseMiddle".action.toggle-overview = [];
  };

  defaultBinds = {
    "Mod+Return".action.spawn = ["ghostty"];
    "Mod+e".action.spawn = [
      "ghostty"
      "-e"
      "yazi"
    ];
    "Mod+o".action.toggle-overview = [];

    "Mod+q".action.close-window = [];
    "Mod+j".action.focus-window-down = [];
    "Mod+k".action.focus-window-up = [];
    "Mod+h".action.focus-column-left-or-last = [];
    "Mod+l".action.focus-column-right-or-first = [];

    "Mod+Shift+j".action.move-window-down = [];
    "Mod+Shift+k".action.move-window-up = [];
    "Mod+Shift+h".action.move-column-left-or-to-monitor-left = [];
    "Mod+Shift+l".action.move-column-right-or-to-monitor-right = [];

    "Mod+Comma".action.consume-window-into-column = [];

    "Mod+Period".action.expel-window-from-column = [];

    "Mod+Control+l".action.set-column-width = "+10%";
    "Mod+Control+h".action.set-column-width = "-10%";
    "Mod+Control+k".action.set-window-height = "+10%";
    "Mod+Control+j".action.set-window-height = "-10%";

    "Mod+f".action.maximize-column = [];
    "Mod+Shift+f".action.maximize-window-to-edges = [];
    "Mod+Escape".action.quit = [];

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;

    "Mod+Shift+1".action.move-window-to-workspace = 1;
    "Mod+Shift+2".action.move-window-to-workspace = 2;
    "Mod+Shift+3".action.move-window-to-workspace = 3;
    "Mod+Shift+4".action.move-window-to-workspace = 4;
    "Mod+Shift+5".action.move-window-to-workspace = 5;
    "Mod+Shift+6".action.move-window-to-workspace = 6;
    "Mod+Shift+7".action.move-window-to-workspace = 7;
    "Mod+Shift+8".action.move-window-to-workspace = 8;
    "Mod+Shift+9".action.move-window-to-workspace = 9;
  };
in {
  options.features.compositors.niri = {
    appearance = {
      gaps = lib.mkOption {
        type = lib.types.int;
        default = cfg.appearance.gaps or 8;
        description = "The gap size between windows.";
      };

      border = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.appearance.border.enable or false;
          description = "Enable border settings.";
        };
        width = lib.mkOption {
          type = lib.types.int;
          default = cfg.appearance.border.width or 2;
          description = "Border width for the appearance settings.";
        };
      };

      radius = lib.mkOption {
        type = lib.types.int;
        default = cfg.appearance.radius or 16;
        description = "Window corner radius for the appearance settings.";
      };

      opacity = {
        active = lib.mkOption {
          type = lib.types.float;
          default = cfg.appearance.opacity.active or 0.95;
          description = "Opacity for active windows.";
        };
        inactive = lib.mkOption {
          type = lib.types.float;
          default = cfg.appearance.opacity.inactive or 0.9;
          description = "Opacity for inactive windows.";
        };
      };
    };

    animations = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.animations.enable or false;
        description = "Whether to enable animations.";
      };
    };

    focus = {
      followsMouse = lib.mkOption {
        type = lib.types.bool;
        default = cfg.focus.followMouse or true;
        description = "Whether to follow the mouse cursor when focusing windows.";
      };
      onActivate = lib.mkOption {
        type = lib.types.bool;
        default = cfg.focus.onActivate or true;
        description = "Whether to focus the window when it is activated.";
      };
    };

    autoStart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = cfg.autoStart or [];
      description = "Commands to run at startup, in addition to shared autoStart.";
    };

    cursor = {
      hideWhileTyping = lib.mkOption {
        type = lib.types.bool;
        default = cfg.cursor.hideWhileTyping or true;
        description = "Whether to hide the cursor while typing.";
      };
      hideTimeout = lib.mkOption {
        type = lib.types.int;
        default = cfg.cursor.hideTimeout or 3;
        description = "Timeout in seconds before the cursor is hidden.";
      };
    };

    input = {
      mouse.enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.input.mouse.enable or false;
        description = "Whether to enable mouse input settings.";
      };

      touchpad = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.enable or false;
          description = "Whether to enable touchpad input settings.";
        };
        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.naturalScrolling or true;
          description = "Whether to enable natural scrolling for the touchpad.";
        };
        tapToClick = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.tapToClick or true;
          description = "Whether to enable tap-to-click for the touchpad.";
        };
        disableWhileTyping = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.disableWhileTyping or true;
          description = "Whether to disable the touchpad while typing.";
        };
        scrollFactor = lib.mkOption {
          type = lib.types.float;
          default = cfg.input.touchpad.scrollFactor or 1.0;
          description = "Scroll factor for the touchpad.";
        };
      };
    };
  };

  config = {
    flake.modules = {
      nixos.niri = {...}: {
        programs.niri = {
          enable = true;
        };

        nix.settings = {
          substituters = ["https://niri.cachix.org"];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          ];
        };
      };

      homeManager.niri = {
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.niri.homeModules.niri
        ];

        systemd.user.services.libinput-gestures = lib.mkIf cfg.niri.input.touchpad.enable {
          gestures = {
            "swipe left 3" = "niri msg action focus-column-left-or-last";
            "swipe right 3" = "niri msg action focus-column-right-or-first";
            "swipe up 3" = "niri msg action focus-column-prev";
            "swipe down 3" = "niri msg action focus-column-next";
          };
        };

        xdg.portal = {
          enable = lib.mkDefault true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
          ];
          config.niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
            "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
            "org.freedesktop.impl.portal.RemoteDesktop" = ["gnome"];
            "org.freedesktop.impl.portal.Inhibit" = ["gnome"];
            "org.freedesktop.impl.portal.Settings" = ["gnome"];
            "org.freedesktop.impl.portal.DynamicLauncher" = ["gnome"];
            "org.freedesktop.impl.portal.Wallpaper" = ["gnome"];
            "org.freedesktop.impl.portal.AppChooser" = ["gtk"];
            "org.freedesktop.impl.portal.Print" = ["gtk"];
            "org.freedesktop.impl.portal.Notification" = ["gtk"];
            "org.freedesktop.impl.portal.Account" = ["gtk"];
            "org.freedesktop.impl.portal.Background" = ["gtk"];
            "org.freedesktop.impl.portal.Email" = ["gtk"];
            "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };
        };

        programs.niri = {
          enable = true;
          package = lib.mkDefault (
            if cfg.niri.package != null
            then cfg.niri.package
            else inputs.niri.packages.${pkgs.system}.niri
          );

          settings = {
            animations.enable = cfg.niri.animations.enable;

            xwayland-satellite = {
              enable = true;
              path = lib.mkDefault (
                if cfg.xwaylandSatellitePackage != null
                then (lib.getExe cfg.xwaylandSatellitePackage)
                else (lib.getExe inputs.niri.packages.${pkgs.system}.xwayland-satellite)
              );
            };

            environment = {
              _JAVA_AWT_WM_NONREPARENTING = "1";
              AWT_TOOLKIT = "MToolkit";
              NIXOS_OZONE_WL = "1";
              MOZ_ENABLE_WAYLAND = "1";
              GDK_BACKEND = "wayland,x11";
              QT_QPA_PLATFORM = "wayland";
              DISPLAY = ":0";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              SDL_VIDEODRIVER = "wayland";
              QT_QPA_PLATFORMTHEME = "gtk3";
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
              NVD_BACKEND = "direct";
            };

            prefer-no-csd = true;

            spawn-at-startup =
              [
                {sh = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";}
              ]
              ++ lib.optional cfg.niri.input.touchpad.enable {argv = ["libinput-gestures-start"];}
              ++ map (cmd: {sh = cmd;}) cfg.niri.autoStart;

            outputs = lib.mkDefault (
              if cfg.monitors != null
              then
                lib.mapAttrs (name: m: {
                  scale = m.scale;
                  variable-refresh-rate = m.vrr.enable;
                  mode = {
                    width = m.resolution.width;
                    height = m.resolution.height;
                    refresh = m.refreshRate;
                  };
                  position = {
                    x = m.position.x;
                    y = m.position.y;
                  };
                })
                cfg.monitors
              else {}
            );

            layout = {
              gaps = cfg.niri.appearance.gaps;

              border = {
                enable = cfg.niri.appearance.border.enable;
                width = cfg.niri.appearance.border.width;
                active.color = "#50C878";
              };

              focus-ring.enable = false;
              shadow.enable = true;
              background-color = "rgba(107, 229, 91, 0)";
              center-focused-column = "never";
              default-column-display = "normal";
              default-column-width = {
                proportion = 1.0;
              };
            };

            layer-rules = [];

            window-rules = [
              {
                geometry-corner-radius = let
                  radius = cfg.niri.appearance.radius * 1.0;
                in {
                  top-left = radius;
                  top-right = radius;
                  bottom-left = radius;
                  bottom-right = radius;
                };
                clip-to-geometry = true;

                draw-border-with-background = false;
              }

              {
                matches = [{is-focused = false;}];
                opacity = cfg.niri.appearance.opacity.inactive;
              }

              {
                matches = [{is-focused = true;}];
                opacity = cfg.niri.appearance.opacity.active;
              }

              {
                matches = [{app-id = "^com\.mitchellh\.ghostty$";}];
                default-column-width = {
                  proportion = 0.5;
                };
              }

              {
                matches = [
                  {
                    app-id = "^com\.mitchellh\.ghostty$";
                    is-focused = true;
                  }
                ];
                opacity = 0.95;
                default-column-width = {
                  proportion = 0.5;
                };
              }

              {
                matches = [
                  {
                    app-id = "^com\.brave\.Browser$";
                    is-focused = true;
                  }
                  {
                    app-id = "^brave-browser$";
                    is-focused = true;
                  }
                ];
                opacity = 1.0;
              }
            ];

            overview.workspace-shadow.enable = false;

            input = {
              keyboard.xkb.layout = lib.mkDefault (
                if cfg.input.keyboard.layout != ""
                then cfg.input.keyboard.layout
                else "de"
              );
              focus-follows-mouse.enable = cfg.niri.focus.followsMouse;
              touchpad = {
                natural-scroll = cfg.niri.input.touchpad.naturalScrolling;
                dwt = cfg.niri.input.touchpad.disableWhileTyping;
                tap = cfg.niri.input.touchpad.tapToClick;
                middle-emulation = true;
                scroll-factor = cfg.niri.input.touchpad.scrollFactor;
              };
            };

            binds =
              {} // defaultBinds // lib.optionalAttrs cfg.niri.input.mouse.enable mouseBinds // cfg.niri.extraBinds;

            cursor = {
              theme = lib.mkDefault (
                if cfg.cursor.theme != ""
                then cfg.cursor.theme
                else "default"
              );
              size = lib.mkDefault cfg.cursor.size;
              hide-on-key-press = cfg.niri.cursor.hideWhileTyping;
              hide-after-inactive-ms = cfg.niri.cursor.hideTimeout * 1000;
            };
          };
        };
      };
    };
  };
}
