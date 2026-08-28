{
  inputs,
  config,
  ...
}:
let
  portalFor =
    pkgs:
    inputs.umbriel.inputs.xdg-desktop-portal-umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  aspects.desktop.compositors.umbriel = {
    description = "The umbriel scrolling Wayland compositor (wlroots + SceneFX), with keybinds and portal wiring.";
    includes = with config.aspectLib.names; [
      desktop.compositors.compositors
      desktop.services.portals
    ];

    nixos = _: {
      imports = [ inputs.umbriel.nixosModules.default ];
      programs.umbriel.enable = true;
    };

    finix =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ ./_module.nix ];

        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;
        };

        programs.umbriel.enable = true;

        environment.systemPackages = [ (portalFor pkgs) ];
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
      in
      {
        imports = [
          inputs.umbriel.hjemModules.default
          ./_binds.nix
          ./_rules.nix
        ];

        options.umbriel.settings = lib.mkOption {
          type = (pkgs.formats.toml { }).type;
          default = { };
          description = ''
            umbriel settings, serialized to ~/.config/umbriel/config.toml.
            Anything left unset falls back to umbriel's own compiled defaults;
            see `''${inputs.umbriel}/examples/config.toml` for the full surface.
          '';
        };

        options.features.compositors.umbriel = {
          extraBinds = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Extra umbriel keybinds: chord -> action string.";
          };
          extraWindowRules = lib.mkOption {
            type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
            default = [ ];
            description = "Extra [[window_rule]] entries, appended to the generated list.";
          };
          extraLayerRules = lib.mkOption {
            type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
            default = [ ];
            description = "Extra [[layer_rule]] entries, appended to the generated list.";
          };
        };

        config = {
          programs.umbriel = {
            enable = true;
            package = pkgs.umbriel;
            settings = config.umbriel.settings;
          };

          umbriel.settings = {
            general.autostart = c.autoStart;

            workspaces.back_and_forth = true;

            environment = {
              _JAVA_AWT_WM_NONREPARENTING = "1";
              AWT_TOOLKIT = "MToolkit";
              NIXOS_OZONE_WL = "1";
              MOZ_ENABLE_WAYLAND = "1";
              GDK_BACKEND = "wayland,x11";
              QT_QPA_PLATFORM = "wayland";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              SDL_VIDEODRIVER = "wayland";
              QT_QPA_PLATFORMTHEME = "gtk3";
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
              NVD_BACKEND = "direct";
            };

            input = {
              keyboard.layout = c.keyboard.layout;

              cursor = {
                size = c.cursor.size;
                theme = "Nordzy-cursors";
                hide_when_typing = true;
                hide_timeout_ms = 3000;
              };

              focus = {
                follows_mouse = true;
                follows_mouse_max_scroll = 0.0;
              };

              touchpad = {
                natural_scroll = true;
                disable_while_typing = true;
              };
            };

            layout = {
              gap = c.gaps.inner;

              scrolling.default_width_fraction = 1.0;
            };

            appearance = {
              border_width = c.borders.width;
              corner_radius = builtins.floor c.borders.radius;
              border_focused = c.colors.active;
              border_unfocused = c.colors.inactive;
            };
          }
          // lib.optionalAttrs (c.monitors != null && c.monitors != { }) {
            output = lib.mapAttrs (
              _: m:
              {
                mode = "${toString m.resolution.width}x${toString m.resolution.height}@${toString m.refreshRate}";
                position = [
                  m.position.x
                  m.position.y
                ];
                inherit (m) scale;
                transform = if m.transform == "0" then "normal" else m.transform;
                vrr = if m.vrr.enable then "always" else "disabled";
              }
              // lib.optionalAttrs (m.hdr != "off") {
                inherit (m) hdr;
                sdr_white = m.sdrWhite;
              }
              // lib.optionalAttrs m.tearing { tearing = true; }
              // lib.optionalAttrs (!m.directScanout) { direct_scanout = false; }
            ) c.monitors;
          };

          features.portals.desktops.umbriel = {
            extraPortals = [
              (portalFor pkgs)
              pkgs.xdg-desktop-portal-gtk
            ];
            backendMap = {
              default = "umbriel;gtk";
              "org.freedesktop.impl.portal.ScreenCast" = "umbriel";
              "org.freedesktop.impl.portal.Screenshot" = "umbriel";
              "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
            };
          };
        };
      };
  };
}
