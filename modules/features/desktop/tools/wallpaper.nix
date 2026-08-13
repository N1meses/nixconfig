{ config, ... }: {
  aspects.desktop.tools.wallpaper = {
    description = "Wallpaper daemon and the wallpaper source directory.";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home =
      {
        lib,
        config,
        pkgs,
        ...
      }:
      let
        c = config.features.compositors;
      in
      {
        options.features.compositors.wallpaper = {
          color = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Solid background color. Defaults to colors.background when null.";
          };
          image = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to wallpaper image. Takes precedence over color.";
          };
        };

        config =
          let
            cfg = config.features.compositors.wallpaper;
            color = if cfg.color != null then cfg.color else c.colors.background;
            cmd =
              if cfg.image != null then
                "${pkgs.swaybg}/bin/swaybg -i ${cfg.image} -m fill"
              else
                "${pkgs.swaybg}/bin/swaybg -c '${color}'";
          in
          {
            packages = [ pkgs.swaybg ];
            features.compositors.autoStart = [ cmd ];
          };
      };
  };
}
