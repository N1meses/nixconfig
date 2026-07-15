{
  config,
  inputs,
  ...
}: let
  mouseBinds = {
    "Mod+WheelScrollDown" = {focus-column-right = [];};
    "Mod+WheelScrollUp" = {focus-column-left = [];};
    "Mod+Ctrl+WheelScrollDown" = {focus-workspace-down = [];};
    "Mod+Ctrl+WheelScrollUp" = {focus-workspace-up = [];};
    "Mod+Shift+WheelScrollDown" = {move-column-right = [];};
    "Mod+Shift+WheelScrollUp" = {move-column-left = [];};
    "Mod+MouseMiddle" = {toggle-overview = [];};
  };

  staticBinds = {
    "Mod+o" = {toggle-overview = [];};
    "Mod+q" = {close-window = [];};
    "Mod+v" = {toggle-window-floating = [];};
    "Mod+j" = {focus-window-down = [];};
    "Mod+k" = {focus-window-up = [];};
    "Mod+h" = {focus-column-left-or-last = [];};
    "Mod+l" = {focus-column-right-or-first = [];};
    "Mod+Shift+j" = {move-window-down = [];};
    "Mod+Shift+k" = {move-window-up = [];};
    "Mod+Shift+h" = {move-column-left-or-to-monitor-left = [];};
    "Mod+Shift+l" = {move-column-right-or-to-monitor-right = [];};
    "Mod+Comma" = {consume-window-into-column = [];};
    "Mod+Period" = {expel-window-from-column = [];};
    "Mod+Control+l" = {set-column-width = "+10%";};
    "Mod+Control+h" = {set-column-width = "-10%";};
    "Mod+Control+k" = {set-window-height = "+10%";};
    "Mod+Control+j" = {set-window-height = "-10%";};
    "Mod+f" = {maximize-column = [];};
    "Mod+Shift+f" = {fullscreen-window = [];};
    "Mod+Escape" = {quit = [];};
    "Print" = {screenshot = [];};
    "Shift+Print" = {screenshot-screen = [];};
    "Ctrl+Print" = {screenshot-window = [];};
    "Mod+1" = {focus-workspace = 1;};
    "Mod+2" = {focus-workspace = 2;};
    "Mod+3" = {focus-workspace = 3;};
    "Mod+4" = {focus-workspace = 4;};
    "Mod+5" = {focus-workspace = 5;};
    "Mod+6" = {focus-workspace = 6;};
    "Mod+7" = {focus-workspace = 7;};
    "Mod+8" = {focus-workspace = 8;};
    "Mod+9" = {focus-workspace = 9;};
    "Mod+Shift+1" = {move-window-to-workspace = 1;};
    "Mod+Shift+2" = {move-window-to-workspace = 2;};
    "Mod+Shift+3" = {move-window-to-workspace = 3;};
    "Mod+Shift+4" = {move-window-to-workspace = 4;};
    "Mod+Shift+5" = {move-window-to-workspace = 5;};
    "Mod+Shift+6" = {move-window-to-workspace = 6;};
    "Mod+Shift+7" = {move-window-to-workspace = 7;};
    "Mod+Shift+8" = {move-window-to-workspace = 8;};
    "Mod+Shift+9" = {move-window-to-workspace = 9;};
  };
in {
    aspects.niri = {
      nixos = {pkgs, ...}: {
        imports = [inputs.niri-nix.nixosModules.default];
        programs.niri = {
          enable = true;
          package = inputs.niri-nix.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        };
      };

      finix = {
        modules,
        lib,
        ...
      }: {
        imports = [modules.niri];
        hardware = {
          graphics = {
            enable = lib.mkDefault true;
            enable32Bit = lib.mkDefault true;
          };
        };
        programs.niri.enable = true;
      };

      home = {
        config,
        lib,
        pkgs,
        ...
      }: let
        c = config.features.compositors;
        termSpawn = [c.terminal.command] ++ c.terminal.args;
        termExec = cmd:
          [c.terminal.command]
          ++ c.terminal.args
          ++ lib.optional (c.terminal.execFlag != "") c.terminal.execFlag
          ++ [cmd];
        r = c.borders.radius * 1.0;
      in {
        imports = [inputs.niri-nix.homeModules.default];

        options.features.compositors.niri = {
          extraBinds = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = {};
          };
        };

        config = {
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

          wayland.windowManager.niri = {
            enable = true;

            settings = {
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

              prefer-no-csd = [];

              spawn-at-startup =
                map (cmd: {_args = ["sh" "-c" cmd];}) c.autoStart;

              output = lib.mkIf (c.monitors != null && c.monitors != {}) (
                lib.mkDefault (
                  lib.mapAttrsToList (
                    name: m: {
                      _args = [name];
                      inherit (m) scale;
                      mode = "${toString m.resolution.width}x${toString m.resolution.height}@${toString m.refreshRate}";
                      position._props = {
                        x = m.position.x;
                        y = m.position.y;
                      };
                    }
                  )
                  c.monitors
                )
              );
              layout = {
                gaps = c.gaps.inner;
                border = {
                  width = c.borders.width;
                  active-color = c.colors.active;
                };
                focus-ring.off = [];
                shadow.on = [];
                background-color = "rgba(107, 229, 91, 0)";
                center-focused-column = "never";
                default-column-display = "normal";
                default-column-width.proportion = 1.0;
              };

              window-rule = [
                {
                  geometry-corner-radius = r;
                  clip-to-geometry = true;
                  draw-border-with-background = false;
                  background-effect = {
                    xray = true;
                    blur = true;
                  };
                }
                {
                  match._props.is-floating = true;
                  max-width = 1024;
                  max-height = 768;
                }
                {
                  match._props.is-focused = false;
                  opacity = c.opacity.unfocused;
                }
                {
                  match._props.is-focused = true;
                  opacity = c.opacity.focused;
                }
                {
                  match._props.app-id = "^${c.terminal.appId}$";
                  default-column-width.proportion = 0.5;
                }
                {
                  match._props = {
                    app-id = "^${c.terminal.appId}$";
                    is-focused = true;
                  };
                  opacity = c.opacity.focused;
                  default-column-width.proportion = 0.5;
                }
                {
                  match._props = {
                    app-id = "^${c.terminal.appId}$";
                    title = "^termfilechooser$";
                  };
                  open-floating = true;
                  default-column-width.fixed = 1024;
                  default-window-height.fixed = 768;
                }
                {
                  match._props = {
                    title = "Bitwarden";
                  };
                  open-floating = true;
                  default-column-width.fixed = 1024;
                  default-window-height.fixed = 768;
                }
                {
                  match = [
                    {_props.app-id = "^com.brave.Browser$";}
                    {_props.app-id = "^brave-browser$";}
                  ];
                  opacity = 1.0;
                }
              ];

              blur = {
                passes = 3;
                offset = 3.0;
                noise = 0.02;
                saturation = 1.5;
              };

              overview.workspace-shadow.off = [];

              input = {
                keyboard.xkb.layout = c.keyboard.layout;
                focus-follows-mouse._props.max-scroll-amount = "0%";
                touchpad = {
                  natural-scroll = [];
                  dwt = [];
                  tap = [];
                  middle-emulation = [];
                  scroll-factor = 1.0;
                };
              };

              xwayland-satellite.path = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
              binds =
                staticBinds
                // mouseBinds
                // {
                  "Mod+Return" = {spawn = termSpawn;};
                  "Mod+e" = {spawn = termExec "yazi";};
                }
                // config.features.compositors.niri.extraBinds;

              cursor = {
                xcursor-theme = "Nordzy-cursors";
                xcursor-size = c.cursor.size;
                hide-when-typing = [];
                hide-after-inactive-ms = 3000;
              };
            };
          };
        };
      };
    };
    aspects.niri.includes = with config.aspectLib.names; [compositors];
}
