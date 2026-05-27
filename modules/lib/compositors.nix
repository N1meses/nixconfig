{...}: let
in {
  flake.modules.homeManager.compositors = {
    lib,
    pkgs,
    ...
  }: {
    options.features.compositors.monitors = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "this monitor";

              resolution = {
                width = lib.mkOption {
                  type = lib.types.int;
                  description = "Monitor width in pixels";
                  example = 2880;
                };
                height = lib.mkOption {
                  type = lib.types.int;
                  description = "Monitor height in pixels";
                  example = 1920;
                };
              };

              refreshRate = lib.mkOption {
                type = lib.types.float;
                description = "Monitor refresh rate in Hz";
                example = 120.0;
                default = 60.0;
              };

              scale = lib.mkOption {
                type = lib.types.float;
                description = "Display scaling factor";
                default = 1.0;
                example = 1.6;
              };

              position = {
                x = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "X position in the layout";
                };
                y = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "Y position in the layout";
                };
              };

              transform = lib.mkOption {
                type = lib.types.enum [
                  "0"
                  "90"
                  "180"
                  "270"
                  "flipped"
                  "flipped-90"
                  "flipped-180"
                  "flipped-270"
                ];
                default = "0";
                description = "Monitor rotation/transform";
              };

              vrr.enable = lib.mkEnableOption "variable refresh rate";
              primary = lib.mkEnableOption "this monitor as primary";
            };
          }
        )
      );
      default = null;
      example = {
        "eDP-1" = {
          resolution = {
            width = 2880;
            height = 1920;
          };
          transform = "0";
          scale = 1.6;
          vrr.enable = true;
          refreshRate = 120.0;
        };
      };
    };

    config = {
      home.packages = with pkgs; [
        wayland-utils
        wl-clipboard
      ];

      services.wl-clip-persist.enable = true;
    };
  };
}
