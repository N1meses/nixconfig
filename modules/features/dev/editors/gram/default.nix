{ inputs, ... }:
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
      let
        helixServers = config.rum.programs.helix.languages.language-server or { };

        # Helix's server attribute names vs gram's adapter names. Anything not
        # listed here passes through unchanged. Verify against gram's own logs
        # before trusting an entry - see Step 3.
        gramName = {
          vscode-css-languageserver = "vscode-css-language-server";
          vscode-html-languageserver = "vscode-html-language-server";
          vscode-json-languageserver = "json-language-server";
        };

        derivedLsps = lib.mapAttrs' (
          name: srv:
          lib.nameValuePair (gramName.${name} or name) {
            binary = {
              path = srv.command;
            }
            // lib.optionalAttrs (srv ? args && srv.args != [ ]) {
              arguments = srv.args;
            };
          }
        ) helixServers;
      in
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
            description = "LSP configs merged over the ones derived from Helix";
          };
          extraSettings = lib.mkOption {
            type = lib.types.attrs;
            default = { };
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

          xdg.config.files."gram/themes/nox-default.json".text = builtins.toJSON (
            import "${inputs.self}/assets/themes/nox/to-zed.nix"
          );

          xdg.config.files."gram/settings.jsonc".text = builtins.toJSON (
            {
              lsp = derivedLsps // config.rum.programs.gram.lsps;
              languages = {
                HTML.language_servers = [ "vscode-html-language-server" ];
                Markdown.language_servers = [ "marksman" ];
              };
              cli_default_open_behavior = "existing_window";
              helix_mode = true;
              theme = "nox-default";
              icon_theme = "Zed (Default)";
              ui_font_size = 18.0;
              buffer_font_size = 18.0;
              node = {
                ignore_system_version = false;
                allow_binary_download = false;
                allow_prettier_download = false;
                allow_npm_install = false;
              };
              telemetry = {
                metrics = false;
              };
            }
            // config.rum.programs.gram.extraSettings
          );

          xdg.config.files."gram/keymap.jsonc".source = ./keymap.jsonc;
        };
      };
  };
}
