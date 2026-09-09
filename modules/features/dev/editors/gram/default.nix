_:
{
  aspects.dev.editors.gram = {
    description = "gram editor a llm free zed fork";

    home =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        # 1. Create the "variables" for other files to write to
        options.rum.programs.gram = {
          extensions = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Zed extensions to install";
          };
          lsps = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "LSP configs to merge into settings.jsonc";
          };
          extraSettings = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Extra Settings which are added";
          };
        };

        config = {
          packages = [ pkgs.gram ];

          files = lib.mkMerge (
            map (ext: {
              ".local/share/gram/extensions/installed/${ext.pname}".source =
                "${ext}/share/zed/extensions/${ext.pname}";
            }) config.rum.programs.gram.extensions
          );

          xdg.config.files."gram/settings.jsonc".text = builtins.toJSON (
            {
              lsp = config.rum.programs.gram.lsps;
              cli_default_open_behavior = "existing_window";
              helix_mode = true;
              icon_theme = "Zed (Default)";
              node = {
                ignore_system_version = false;
                allow_binary_download = false;
                allow_prettier_download = false;
                allow_npm_install = false;
              };
              ui_font_size = 18.0;
              buffer_font_size = 18.0;
              telemetry = {
                metrics = false;
              };
            } // config.rum.programs.gram.extraSettings
          );

          xdg.config.files."gram/keymap.jsonc".source = ./keymap.jsonc;
        };
      };
  };
}
