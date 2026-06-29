{inputs, ...}: let
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
in {
  flake.modules = {
    nixos.hyprland = _: {
      programs.hyprland.enable = true;
    };

    homeManager.hyprland = {
      config,
      lib,
      pkgs,
      ...
    }: let
      c = config.features.compositors;
      toHypr = hex: "rgb(${lib.removePrefix "#" hex})";
      termArgs = lib.optionalString (c.terminal.args != []) " ${lib.concatStringsSep " " c.terminal.args}";
      termExec = cmd:
        "${c.terminal.command}${termArgs}"
        + lib.optionalString (c.terminal.execFlag != "") " ${c.terminal.execFlag}"
        + " ${cmd}";
    in {
      imports = [inputs.hyprland.homeManagerModules.default];

      options.features.compositors.hyprland = {
        extraBinds = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        input.touchpad.enable = lib.mkEnableOption "touchpad input and gestures";
      };

      config = {
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
          portalPackage = lib.mkDefault inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

          settings = {
            monitor =
              if c.monitors != null
              then
                lib.mapAttrsToList
                (name: m: "${name},${toString m.resolution.width}x${toString m.resolution.height}@${toString (builtins.floor m.refreshRate)},${toString m.position.x}x${toString m.position.y},${toString m.scale}")
                c.monitors
              else [];

            env = [
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
              "XCURSOR_SIZE,${toString c.cursor.size}"
              "HYPRCURSOR_SIZE,${toString c.cursor.size}"
            ];

            exec-once =
              [
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              ]
              ++ c.autoStart;

            general = {
              gaps_in = lib.mkDefault c.gaps.inner;
              gaps_out = lib.mkDefault c.gaps.outer;
              border_size = lib.mkDefault c.borders.width;
              "col.active_border" = toHypr c.colors.active;
              "col.inactive_border" = toHypr c.colors.inactive;
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
              rounding = lib.mkDefault c.borders.radius;
              active_opacity = lib.mkDefault c.opacity.focused;
              inactive_opacity = lib.mkDefault c.opacity.unfocused;
              shadow.enabled = false;
            };

            animations = {
              enabled = lib.mkDefault true;
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
              kb_layout = lib.mkDefault c.keyboard.layout;
              follow_mouse = lib.mkDefault 1;
              touchpad = lib.mkIf config.features.compositors.hyprland.input.touchpad.enable {
                natural_scroll = lib.mkDefault true;
                disable_while_typing = lib.mkDefault true;
                clickfinger_behavior = lib.mkDefault true;
                scroll_factor = lib.mkDefault 1.0;
              };
            };

            cursor = {
              hide_on_touch = lib.mkDefault true;
              inactive_timeout = lib.mkDefault 3;
            };

            misc = {
              disable_hyprland_logo = true;
              focus_on_activate = lib.mkDefault true;
              disable_hyprland_guiutils_check = true;
            };

            xwayland.force_zero_scaling = true;
            debug.disable_logs = false;

            windowrule = [
              "opacity 0.95 0.9"
              "opacity 1.0 0.9, match:class ^com\\.brave\\.Browser$"
              "opacity 1.0 0.9, match:class ^brave-browser$"
              "opacity 0.95 0.90, match:class ^${c.terminal.appId}$"
              "match:title ^(Open File)$, float on"
              "match:title ^(Save As)$, float on"
              "match:title ^(Picture-in-Picture)$, float on"
              "match:title ^(Picture-in-Picture)$, pin on"
              "match:title ^(Picture-in-Picture)$, size 640 360"
            ];

            bind =
              [
                "SUPER,Return,exec,${c.terminal.command}${termArgs}"
                "SUPER,E,exec,${termExec "yazi"}"
              ]
              ++ window_binds
              ++ workspace_binds
              ++ config.features.compositors.hyprland.extraBinds;

            gestures = lib.mkIf config.features.compositors.hyprland.input.touchpad.enable {
              workspace_swipe = true;
              workspace_swipe_fingers = 3;
            };
          };
        };
      };
    };
  };
}
