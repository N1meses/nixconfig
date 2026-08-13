{
  config,
  ...
}:
{
  aspects.desktop.compositors.halley = {
    finix =
      {
        lib,
        ...
      }:
      {
        imports = [ ./_module.nix ];

        programs.halley.enable = true;

        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;
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
        cfg = config.features.compositors.halley;

        term = c.terminal.command;
        termExec = "${term}${lib.optionalString (c.terminal.execFlag != "") " ${c.terminal.execFlag}"}";

        monitorsBlock = lib.optionalString (c.monitors != null && c.monitors != { }) ''
          viewport:
          ${lib.concatStrings (
            lib.mapAttrsToList (name: m: ''
              ${name}:
                enabled true
                width ${toString m.resolution.width}
                height ${toString m.resolution.height}
                rate ${toString m.refreshRate}
                transform ${m.transform}
                vrr "${if m.vrr.enable then "on" else "off"}"
                offset-x ${toString m.position.x}
                offset-y ${toString m.position.y}
              end
            '') c.monitors
          )}
          end
        '';

        autostartBlock = lib.optionalString (c.autoStart != [ ]) ''
          autostart:
          ${lib.concatMapStringsSep "\n" (cmd: "  once \"${cmd}\"") c.autoStart}
          end
        '';

        baseKeybinds = ''
          # focus — niri hjkl, context-aware (field focus / tile / stack),
          # mirroring the arrow binds so vim keys work everywhere arrows do.
          "$var.mod+h" "focus-left"
          "$var.mod+h" "tile-focus left"
          "$var.mod+h" "stack-cycle forward"
          "$var.mod+j" "focus-down"
          "$var.mod+j" "tile-focus down"
          "$var.mod+k" "focus-up"
          "$var.mod+k" "tile-focus up"
          "$var.mod+l" "focus-right"
          "$var.mod+l" "tile-focus right"
          "$var.mod+l" "stack-cycle backward"

          # move node — shift+hjkl
          "$var.mod+shift+h" "node-move left"
          "$var.mod+shift+j" "node-move down"
          "$var.mod+shift+k" "node-move up"
          "$var.mod+shift+l" "node-move right"

          # swap tiles — ctrl+hjkl
          "$var.mod+ctrl+h" "tile-swap left"
          "$var.mod+ctrl+j" "tile-swap down"
          "$var.mod+ctrl+k" "tile-swap up"
          "$var.mod+ctrl+l" "tile-swap right"

          # focus other monitor — ctrl+shift+hl
          "$var.mod+ctrl+shift+h" "monitor-focus left"
          "$var.mod+ctrl+shift+l" "monitor-focus right"

          # window ops
          "$var.mod+q" "close-focused"
          "$var.mod+f" "maximize-focused"
          "$var.mod+shift+f" "toggle-fullscreen"
          "$var.mod+p" "toggle-focused-pin"
          "$var.mod+o" "apogee"
          "$var.mod+shift+e" "quit"
          "$var.mod+shift+r" "reload"

          # clusters — niri workspaces
          "$var.mod+1" "cluster slot 1"
          "$var.mod+2" "cluster slot 2"
          "$var.mod+3" "cluster slot 3"
          "$var.mod+4" "cluster slot 4"
          "$var.mod+5" "cluster slot 5"
          "$var.mod+6" "cluster slot 6"
          "$var.mod+7" "cluster slot 7"
          "$var.mod+8" "cluster slot 8"
          "$var.mod+9" "cluster slot 9"
          "$var.mod+0" "cluster slot 10"
          "$var.mod+shift+c" "cluster-mode"
          "$var.mod+g" "cluster-layout cycle"

          # field navigation — Halley spatial layer
          "$var.mod+space" "center-last-focused"
          "$var.mod+z" "bearings-show"
          "$var.mod+shift+z" "bearings-toggle"
          "$var.mod+," "trail-prev"
          "$var.mod+." "trail-next"
          "$var.mod+mousewheelup" "zoom-in"
          "$var.mod+mousewheeldown" "zoom-out"
          "$var.mod+middlemouse" "zoom-reset"
          "$var.mod+leftmouse" "move-window"
          "$var.mod+rightmouse" "resize-window"
          "$var.mod+shift+leftmouse" "pan-field"

          # focus cycle
          "alt+tab" "cycle-focus"
          "alt+shift+tab" "cycle-focus-backward"

          # apps (terminal/launcher from options)
          "$var.mod+return" "${term}"
          "$var.mod+e" "${termExec} yazi"
          "$var.mod+d" "${c.launcher.command}"
        '';

        extraBindsBlock = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (k: v: "  \"${k}\" \"${v}\"") cfg.extraBinds
        );
      in
      {
        options.features.compositors.halley = {
          extraBinds = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Extra Halley keybinds: rune key combo -> action/spawn command.";
          };
          extraConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "Raw rune appended to the generated halley.rune (e.g. rules, effects).";
          };
        };

        config = {
          xdg.config.files."halley/default.rune".source = ./default.rune;

          xdg.config.files."halley/halley.rune".text = ''
            gather "default.rune"

            input:
              keyboard:
                layout "${c.keyboard.layout}"
              end
            end

            cursor:
              size ${toString c.cursor.size}
            end

            clusters:
              default-layout "tiling"
            end

            tile:
              gaps-inner ${toString c.gaps.inner}
              gaps-outer ${toString c.gaps.outer}
            end

            ${monitorsBlock}
            ${autostartBlock}
            keybinds:
              mod "super"
            ${baseKeybinds}
            ${extraBindsBlock}
            end

            ${cfg.extraConfig}
          '';

          features.portals.desktops.halley = {
            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-termfilechooser
            ];
            backendMap = {
              default = "gtk";
              "org.freedesktop.impl.portal.ScreenCast" = "halley";
              "org.freedesktop.impl.portal.Screenshot" = "halley";
              "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
            };
          };
        };
      };
    description = "The halley Wayland compositor.";
    includes = with config.aspectLib.names; [
      desktop.compositors.compositors
      desktop.services.portals
    ];
  };

}
