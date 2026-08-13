{
  config,
  inputs,
  ...
}:
{
  aspects.hyprland.description = "The Hyprland Wayland compositor.";
  aspects.hyprland = {
    nixos = { pkgs, ... }: {
      programs.hyprland = {
        enable = true;
        package = pkgs.hyprland;
      };
    };

    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        c = config.features.compositors;
        hcfg = config.features.compositors.hyprland;

        toHypr = hex: "rgb(${lib.removePrefix "#" hex})";

        termArgs = lib.optionalString (
          c.terminal.args != [ ]
        ) " ${lib.concatStringsSep " " c.terminal.args}";
        term = "${c.terminal.command}${termArgs}";
        termExec =
          cmd: term + lib.optionalString (c.terminal.execFlag != "") " ${c.terminal.execFlag}" + " ${cmd}";

        env = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          GDK_BACKEND = "wayland,x11";
          QT_QPA_PLATFORM = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          SDL_VIDEODRIVER = "wayland";
          _JAVA_AWT_WM_NONREPARENTING = "1";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          AWT_TOOLKIT = "MToolkit";
          QT_QPA_PLATFORMTHEME = "gtk3";
          NVD_BACKEND = "direct";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          XCURSOR_SIZE = toString c.cursor.size;
          HYPRCURSOR_SIZE = toString c.cursor.size;
        };
        envBlock = lib.concatStrings (lib.mapAttrsToList (k: v: ''hl.env("${k}", "${v}")'' + "\n") env);

        monitorsBlock =
          if (c.monitors != null && c.monitors != { }) then
            lib.concatStrings (
              lib.mapAttrsToList (
                name: m:
                ''hl.monitor({ output = "${name}", mode = "${toString m.resolution.width}x${toString m.resolution.height}@${toString m.refreshRate}", position = "${toString m.position.x}x${toString m.position.y}", scale = ${toString m.scale} })''
                + "\n"
              ) c.monitors
            )
          else
            ''hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })'' + "\n";

        autostartBlock = lib.concatMapStrings (cmd: "  hl.exec_cmd([[${cmd}]])\n") (
          [
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          ]
          ++ c.autoStart
        );

        touchpadBlock = lib.optionalString hcfg.input.touchpad.enable ''

          natural_scroll = true,
          disable_while_typing = true,
          clickfinger_behavior = true,
          scroll_factor = 1.0,
        '';

        gestureBlock = lib.optionalString hcfg.input.touchpad.enable ''hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })'';

        extraBindsBlock = lib.concatStringsSep "\n" hcfg.extraBinds;
      in
      {
        options.features.compositors.hyprland = {
          extraBinds = lib.mkOption {
            type = lib.types.listOf lib.types.lines;
            default = [ ];
            description = "Extra raw Lua (hl.bind(...) lines) appended to hyprland.lua.";
          };
          input.touchpad.enable = lib.mkEnableOption "touchpad input and gestures";
        };

        config = {
          features.portals.desktops.Hyprland = {
            extraPortals = [
              inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
              pkgs.xdg-desktop-portal-gtk
            ];
            backendMap = {
              default = "hyprland;gtk";
              "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
              "org.freedesktop.impl.portal.Screenshot" = "hyprland";
              "org.freedesktop.impl.portal.RemoteDesktop" = "hyprland";
            };
          };

          xdg.config.files."hypr/hyprland.lua".source = pkgs.replaceVars ./hyprland.lua {
            monitors = monitorsBlock;
            env = envBlock;
            gaps_in = toString c.gaps.inner;
            gaps_out = toString c.gaps.outer;
            border_size = toString c.borders.width;
            active_border = toHypr c.colors.active;
            inactive_border = toHypr c.colors.inactive;
            rounding = toString c.borders.radius;
            active_opacity = toString c.opacity.focused;
            inactive_opacity = toString c.opacity.unfocused;
            kb_layout = c.keyboard.layout;
            touchpad = touchpadBlock;
            gesture = gestureBlock;
            autostart = autostartBlock;
            term_class = c.terminal.appId;
            term = term;
            yazi = termExec "yazi";
            extrabinds = extraBindsBlock;
          };
        };
      };
  };
  aspects.hyprland.includes = with config.aspectLib.names; [
    compositors
    portals
  ];
}
