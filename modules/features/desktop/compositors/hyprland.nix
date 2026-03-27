{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.features.compositors;

  workspace_binds = [
    "SUPER,1,workspace,1"
    "SUPER,2,workspace,2"
    "SUPER,3,workspace,3"
    "SUPER,4,workspace,4"
    "SUPER,5,workspace,5"
    "SUPER,6,workspace,6"
    "SUPER,7,workspace,7"
    "SUPER,8,workspace,8"
    "SUPER,9,workspace,9"
    "SUPERSHIFT,1,movetoworkspace,1"
    "SUPERSHIFT,2,movetoworkspace,2"
    "SUPERSHIFT,3,movetoworkspace,3"
    "SUPERSHIFT,4,movetoworkspace,4"
    "SUPERSHIFT,5,movetoworkspace,5"
    "SUPERSHIFT,6,movetoworkspace,6"
    "SUPERSHIFT,7,movetoworkspace,7"
    "SUPERSHIFT,8,movetoworkspace,8"
    "SUPERSHIFT,9,movetoworkspace,9"
  ];

  window_binds = [
    "SUPER,Q,killactive"
    "SUPER,F,fullscreen,1"
    "SUPERSHIFT,f,fullscreen,0"
    "SUPER,ESC,exit"
    "SUPER,H,movefocus,l"
    "SUPER,J,movefocus,d"
    "SUPER,K,movefocus,u"
    "SUPER,L,movefocus,r"
    "SUPERSHIFT,H,movewindow,l"
    "SUPERSHIFT,J,movewindow,d"
    "SUPERSHIFT,K,movewindow,u"
    "SUPERSHIFT,L,movewindow,r"
    "SUPERCTRL,H,resizeactive,-10% 0"
    "SUPERCTRL,L,resizeactive,10% 0"
    "SUPERCTRL,K,resizeactive,0 -10%"
    "SUPERCTRL,J,resizeactive,0 10%"
    "SUPER,V,togglefloating"
    "SUPER,C,centerwindow"
  ];

  launching_binds = [
    "SUPER,Return,exec,ghostty"
    "SUPER,E,exec,ghostty -e yazi"
  ];
in {
  options.features.compositors.hyprland = {
    appearance = {
      gaps = lib.mkOption {
        type = lib.types.int;
        default = cfg.appearance.gaps or 8;
        description = "Gap size between windows.";
      };

      border = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.appearance.border.enable or false;
          description = "Enable window borders.";
        };
        width = lib.mkOption {
          type = lib.types.int;
          default = cfg.appearance.border.width or 2;
          description = "Border width in pixels.";
        };
      };

      radius = lib.mkOption {
        type = lib.types.int;
        default = cfg.appearance.radius or 16;
        description = "Window corner radius.";
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

    animations.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.animations.enable or false;
      description = "Whether to enable animations.";
    };

    focus = {
      followsMouse = lib.mkOption {
        type = lib.types.bool;
        default = cfg.focus.followMouse or false;
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

    input = {
      touchpad = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.enable or false;
          description = "Whether to enable touchpad settings.";
        };
        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.naturalScrolling or true;
          description = "Whether to enable natural scrolling.";
        };
        tapToClick = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.tapToClick or true;
          description = "Whether to enable tap-to-click.";
        };
        disableWhileTyping = lib.mkOption {
          type = lib.types.bool;
          default = cfg.input.touchpad.disableWhileTyping or true;
          description = "Whether to disable touchpad while typing.";
        };
        scrollFactor = lib.mkOption {
          type = lib.types.float;
          default = cfg.input.touchpad.scrollFactor or 1.0;
          description = "Touchpad scroll speed multiplier.";
        };
      };
    };
  };

  config = {
    flake.modules = {
      nixos.hyprland = {...}: {
        programs.hyprland.enable = true;
      };

      homeManager.hyprland = {
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.hyprland.homeManagerModules.default
        ];

        xdg.portal = {
          enable = lib.mkDefault true;
          extraPortals = [
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
            pkgs.xdg-desktop-portal-gtk
          ];
          config.hyprland = {
            default = ["hyprland" "gtk"];
            "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
            "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
            "org.freedesktop.impl.portal.RemoteDesktop" = ["hyprland"];
          };
        };

        wayland.windowManager.hyprland = {
          enable = true;
          package = lib.mkForce (
            if cfg.hyprland.package != null
            then cfg.hyprland.package
            else inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
          );
          portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

          settings = {
            monitor =
              if cfg.monitors != null
              then
                lib.mapAttrsToList (name: m: "${name},${toString m.resolution.width}x${toString m.resolution.height}@${toString (builtins.floor m.refreshRate)},${toString m.position.x}x${toString m.position.y},${toString m.scale}")
                cfg.monitors
              else [];

            env =
              [
                "NIXOS_OZONE_WL,1"
                "MOZ_ENABLE_WAYLAND,1"
                "GDK_BACKEND,wayland,x11"
                "QT_QPA_PLATFORM,wayland"
                "XDG_CURRENT_DESKTOP,Hyprland"
                "XDG_SESSION_TYPE,wayland"
                "XDG_SESSION_DESKTOP,Hyprland"
                "SDL_VIDEODRIVER,wayland"
                "_JAVA_AWT_WM_NONREPARENTING,1"
                "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                "AWT_TOOLKIT,MToolkit"
                "QT_QPA_PLATFORMTHEME,gtk3"
                "NVD_BACKEND,direct"
                "ELECTRON_OZONE_PLATFORM_HINT,auto"
                "XCURSOR_SIZE,${toString cfg.cursor.size}"
                "HYPRCURSOR_SIZE,${toString cfg.cursor.size}"
              ]
              ++ lib.optional (cfg.cursor.theme != "") "XCURSOR_THEME,${cfg.cursor.theme}"
              ++ lib.optional (cfg.cursor.theme != "") "HYPRCURSOR_THEME,${cfg.cursor.theme}";

            exec-once =
              [
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              ]
              ++ cfg.hyprland.autoStart;

            general = {
              gaps_in = cfg.hyprland.appearance.gaps / 2;
              gaps_out = cfg.hyprland.appearance.gaps;
              border_size =
                if cfg.hyprland.appearance.border.enable
                then cfg.hyprland.appearance.border.width
                else 0;
              "col.active_border" = "rgb(50C878)";
              "col.inactive_border" = "rgb(595959)";
              resize_on_border = true;
            };

            dwindle = {
              pseudotile = true;
              preserve_split = true;
            };

            master.new_status = "slave";

            scrolling = {
              direction = "right";
              fullscreen_on_one_column = true;
              follow_focus = true;
            };

            workspace = [
              "1, layout:dwindle"
              "2, layout:scroll"
              "3, layout:scroll"
              "4, layout:dwindle"
              "5, layout:scroll"
              "6, layout:scroll"
              "7, layout:dwindle"
              "8, layout:scroll"
              "9, layout:scroll"
            ];

            decoration = {
              rounding = cfg.hyprland.appearance.radius;
              active_opacity = cfg.hyprland.appearance.opacity.active;
              inactive_opacity = cfg.hyprland.appearance.opacity.inactive;
              shadow.enabled = false;
            };

            animations = {
              enabled = cfg.hyprland.animations.enable;
              bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
              animation = [
                "windows, 1, 3, myBezier"
                "windowsOut, 1, 3, default, popin 80%"
                "border, 1, 4, default"
                "borderangle, 1, 4, default"
                "fade, 1, 3, default"
                "workspaces, 1, 3, default"
              ];
            };

            input = {
              kb_layout = lib.mkDefault (
                if cfg.input.keyboard.layout != ""
                then cfg.input.keyboard.layout
                else "de"
              );
              follow_mouse =
                if cfg.hyprland.focus.followsMouse
                then 1
                else 0;
              touchpad = lib.mkIf cfg.hyprland.input.touchpad.enable {
                natural_scroll = cfg.hyprland.input.touchpad.naturalScrolling;
                disable_while_typing = cfg.hyprland.input.touchpad.disableWhileTyping;
                clickfinger_behavior = cfg.hyprland.input.touchpad.tapToClick;
                scroll_factor = cfg.hyprland.input.touchpad.scrollFactor;
              };
            };

            cursor = {
              hide_on_touch = cfg.cursor.hideWhileTyping;
              inactive_timeout = cfg.cursor.hideTimeout;
            };

            misc = {
              disable_hyprland_logo = true;
              focus_on_activate = cfg.hyprland.focus.onActivate;
              disable_hyprland_guiutils_check = true;
            };

            xwayland.force_zero_scaling = true;

            debug.disable_logs = false;

            windowrule = [
              "opacity ${toString cfg.hyprland.appearance.opacity.active} ${toString cfg.hyprland.appearance.opacity.inactive}"
              "opacity 1.0 0.9, match:class ^com\\.brave\\.Browser$"
              "opacity 1.0 0.9, match:class ^brave-browser$"
              "opacity 0.95 0.90, match:class ^com\\.mitchellh\\.ghostty$"
              "match:title ^(Open File)$, float on"
              "match:title ^(Save As)$, float on"
              "match:title ^(Picture-in-Picture)$, float on"
              "match:title ^(Picture-in-Picture)$, pin on"
              "match:title ^(Picture-in-Picture)$, size 640 360"
            ];

            bind = [] ++ window_binds ++ workspace_binds ++ launching_binds ++ cfg.hyprland.extraBinds;

            gestures = lib.mkIf cfg.hyprland.input.touchpad.enable {
              workspace_swipe = true;
              workspace_swipe_fingers = 3;
            };
          };
        };
      };
    };
  };
}
