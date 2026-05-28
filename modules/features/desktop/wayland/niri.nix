{inputs, ...}: let
  mouseBinds = {
    "Mod+WheelScrollDown".action.focus-column-right = [];
    "Mod+WheelScrollUp".action.focus-column-left = [];
    "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = [];
    "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = [];
    "Mod+Shift+WheelScrollDown".action.move-column-right = [];
    "Mod+Shift+WheelScrollUp".action.move-column-left = [];
    "Mod+MouseMiddle".action.toggle-overview = [];
  };

  staticBinds = {
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
  flake.modules = {
    nixos.niri = {...}: {
      programs.niri.enable = true;
      nix.settings = {
        substituters = ["https://niri.cachix.org"];
        trusted-public-keys = [
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];
      };
    };

    homeManager.niri = {
      config,
      lib,
      pkgs,
      ...
    }: let
      c = config.features.compositors;
      termSpawn = [c.terminal.command];
      termExec = cmd:
        [c.terminal.command]
        ++ lib.optional (c.terminal.execFlag != "") c.terminal.execFlag
        ++ [cmd];
      r = c.borders.radius * 1.0;
    in {
      imports = [
        inputs.niri.homeModules.niri
      ];

      options.features.compositors.niri = {
        extraBinds = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = {};
        };
        autoStart = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        input.touchpad.enable = lib.mkEnableOption "touchpad input and gestures";
      };

      config = {
        systemd.user.services.libinput-gestures = lib.mkIf config.features.compositors.niri.input.touchpad.enable {
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
            default = ["gnome" "gtk"];
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
          package = lib.mkDefault inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;

          settings = {
            animations.enable = lib.mkDefault true;

            xwayland-satellite = {
              enable = true;
              path = lib.mkDefault (lib.getExe inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite-unstable);
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
              ++ lib.optional config.features.compositors.niri.input.touchpad.enable {argv = ["libinput-gestures-start"];}
              ++ map (cmd: {sh = cmd;}) config.features.compositors.niri.autoStart;

            outputs = lib.mkDefault (
              if c.monitors != null
              then
                lib.mapAttrs (_: m: {
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
                c.monitors
              else {}
            );

            layout = {
              gaps = lib.mkDefault c.gaps.inner;
              border = {
                enable = lib.mkDefault true;
                width = lib.mkDefault c.borders.width;
                active.color = c.colors.active;
              };
              focus-ring.enable = false;
              shadow.enable = true;
              background-color = "rgba(107, 229, 91, 0)";
              center-focused-column = "never";
              default-column-display = "normal";
              default-column-width.proportion = 1.0;
            };

            layer-rules = [];

            window-rules = [
              {
                geometry-corner-radius = {
                  top-left = r;
                  top-right = r;
                  bottom-left = r;
                  bottom-right = r;
                };
                clip-to-geometry = true;
                draw-border-with-background = false;
              }
              {
                matches = [{is-focused = false;}];
                opacity = c.opacity.unfocused;
              }
              {
                matches = [{is-focused = true;}];
                opacity = c.opacity.focused;
              }
              {
                matches = [{app-id = "^com\\.mitchellh\\.ghostty$";}];
                default-column-width.proportion = 0.5;
              }
              {
                matches = [
                  {
                    app-id = "^com\\.mitchellh\\.ghostty$";
                    is-focused = true;
                  }
                ];
                opacity = c.opacity.focused;
                default-column-width.proportion = 0.5;
              }
              {
                matches = [{app-id = "^com\\.brave\\.Browser$";} {app-id = "^brave-browser$";}];
                opacity = 1.0;
              }
            ];

            overview.workspace-shadow.enable = false;

            input = {
              keyboard.xkb.layout = lib.mkDefault c.keyboard.layout;
              focus-follows-mouse.enable = lib.mkDefault true;
              touchpad = {
                natural-scroll = lib.mkDefault true;
                dwt = lib.mkDefault true;
                tap = lib.mkDefault true;
                middle-emulation = true;
                scroll-factor = lib.mkDefault 1.0;
              };
            };

            binds =
              staticBinds
              // mouseBinds
              // {
                "Mod+Return".action.spawn = termSpawn;
                "Mod+e".action.spawn = termExec "yazi";
              }
              // config.features.compositors.niri.extraBinds;

            cursor = {
              theme = lib.mkDefault "Nordzy-cursors";
              size = lib.mkDefault c.cursor.size;
              hide-on-key-press = lib.mkDefault true;
              hide-after-inactive-ms = lib.mkDefault 3000;
            };
          };
        };
      };
    };
  };
}
