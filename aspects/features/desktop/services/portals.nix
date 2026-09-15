_: {
  aspects.desktop.services.portals = {
    nixos = { lib, ... }: {
      services.dbus.enable = lib.mkDefault true;
      services.udisks2.enable = lib.mkDefault true;
    };

    finix =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          xdg-desktop-portal
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
          xdg-desktop-portal-termfilechooser
        ];
      };

    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.features.portals;
        ini = pkgs.formats.ini { };
        backendType = lib.types.attrsOf lib.types.str;
      in
      {
        options.features.portals = {
          desktops = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  backendMap = lib.mkOption {
                    type = backendType;
                    default = { };
                    description = "[preferred] section: interface -> backend (semicolon-separated for fallbacks).";
                  };
                  extraPortals = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                    description = "Portal backend packages (xdg-desktop-portal-*).";
                  };
                };
              }
            );
            default = { };
          };

          commonBackends = lib.mkOption {
            type = backendType;
            default = { };
          };
        };

        config = lib.mkIf (cfg.desktops != { }) {
          packages = [
            pkgs.xdg-desktop-portal
            pkgs.xdg-utils
          ]
          ++ lib.concatMap (d: d.extraPortals) (lib.attrValues cfg.desktops);

          environment.sessionVariables.GTK_USE_PORTAL = "1";

          xdg.config.files = lib.mapAttrs' (
            name: d:
            lib.nameValuePair "xdg-desktop-portal/${name}-portals.conf" {
              source = ini.generate "${name}-portals.conf" { preferred = cfg.commonBackends // d.backendMap; };
            }
          ) cfg.desktops;
        };
      };
    description = "xdg-desktop-portal backends and per-compositor backend routing.";
  };
}
