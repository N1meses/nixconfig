_: {
  # Shared mimeapps.list: multiple aspects (browser, helix, …) contribute to
  # features.mimeApps.*, and this emits the single ~/.config/mimeapps.list.
  aspects.mimeApps.home = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.features.mimeApps;
    ini = pkgs.formats.ini {listToValue = lib.concatStringsSep ";";};
  in {
    options.features.mimeApps = {
      defaultApplications = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
      };
      addedAssociations = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
      };
    };

    config = lib.mkIf (cfg.defaultApplications != {} || cfg.addedAssociations != {}) {
      xdg.config.files."mimeapps.list".source = ini.generate "mimeapps.list" {
        "Default Applications" = cfg.defaultApplications;
        "Added Associations" = cfg.addedAssociations;
      };
    };
  };
}
