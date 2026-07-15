_: {
  aspects.portalsHjem.home = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.features.portals;
    ini = pkgs.formats.ini {};
  in {
    options.features.portals = {
      desktop = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "XDG_CURRENT_DESKTOP name; selects <desktop>-portals.conf.";
      };
      backendMap = lib.mkOption {
        type = ini.type;
        default = {};
        description = ''
          Contents of the [preferred] section: interface -> backend string
          (semicolon-separated for multiple, e.g. "gnome;gtk").
        '';
      };
      extraPortals = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Portal backend packages (xdg-desktop-portal-*).";
      };
    };

    config = lib.mkIf (cfg.desktop != null) {
      packages = [pkgs.xdg-desktop-portal] ++ cfg.extraPortals;
      xdg.config.files."xdg-desktop-portal/${cfg.desktop}-portals.conf".source =
        ini.generate "${cfg.desktop}-portals.conf" {preferred = cfg.backendMap;};
    };
  };
}
