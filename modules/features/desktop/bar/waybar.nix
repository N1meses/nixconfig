{config, ...}: {
  flake = {
    modules.homeManager.waybar = {config, ...}: let
      c = config.features.compositors;
      bg = c.colors.background;
      active = c.colors.active;
      fg = "#d4d4d4";
      dim = "#888888";
    in {
      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 28;
          spacing = 0;

          modules-left = ["niri/workspaces" "niri/window"];
          modules-center = ["clock"];
          modules-right = ["wireplumber" "battery"];

          "niri/workspaces" = {
            on-click = "activate";
            format = "{name}";
          };

          "niri/window" = {
            format = "  {title}";
            max-length = 60;
          };

          clock = {
            format = "{:%H:%M}";
            format-alt = "{:%a %d %b  %H:%M}";
            tooltip = false;
          };

          wireplumber = {
            format = " {volume}%";
            format-muted = " muted";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            max-volume = 150;
            scroll-step = 5;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-icons = ["" "" "" "" ""];
            tooltip = false;
          };
        };

        style = ''
          * {
            font-family: "IBM Plex Mono", monospace;
            font-size: 12px;
            border: none;
            border-radius: 0;
            padding: 0;
            margin: 0;
            min-height: 0;
          }

          window#waybar {
            background-color: ${bg};
            color: ${fg};
            border-bottom: ${toString c.borders.width}px solid ${active};
          }

          #workspaces { padding: 0 4px; }

          #workspaces button {
            padding: 0 8px;
            color: ${dim};
            background: transparent;
            border-radius: 0;
          }

          #workspaces button.active { color: ${active}; }
          #workspaces button.urgent { color: #ff5555; }

          #workspaces button:hover {
            background: transparent;
            color: ${fg};
            box-shadow: none;
            text-shadow: none;
          }

          #window {
            color: ${dim};
            padding: 0 8px;
          }

          #clock,
          #battery,
          #wireplumber {
            padding: 0 10px;
            color: ${fg};
          }

          #battery.warning  { color: #f1fa8c; }
          #battery.critical { color: #ff5555; }
          #battery.charging { color: ${active}; }
        '';
      };
    };
    aspectInclude.waybar = with config.flake.lib.aspects; [compositors];
  };
}
