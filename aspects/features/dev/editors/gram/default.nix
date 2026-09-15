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

        gramName = {
          vscode-css-languageserver = "vscode-css-language-server";
          vscode-html-languageserver = "vscode-html-language-server";
          vscode-json-languageserver = "json-language-server";
        };

        serverLanguages = {
          nixd = [ "Nix" ];
          pyright = [ "Python" ];
          rust-analyzer = [ "Rust" ];
          marksman = [ "Markdown" ];
          lua-language-server = [ "Lua" ];
          zls = [ "Zig" ];
          gopls = [ "Go" ];
          clangd = [
            "C"
            "C++"
          ];
          bash-language-server = [ "bash" ];
          yaml-language-server = [ "YAML" ];
          json-language-server = [
            "JSON"
            "JSONC"
          ];
          vscode-html-language-server = [ "HTML" ];
          vscode-css-language-server = [ "CSS" ];
          typescript-language-server = [
            "TypeScript"
            "TSX"
            "JavaScript"
          ];
        };

        derivedLsps = lib.mapAttrs' (
          name: srv:
          lib.nameValuePair (gramName.${name} or name) (
            {
              binary = {
                path =
                  srv.command
                    or (throw "gram: helix language-server '${name}' has no 'command'; cannot derive a gram lsp entry");
                allow_binary_download = false;
              }
              // lib.optionalAttrs (srv ? args && srv.args != [ ]) {
                arguments = srv.args;
              };
            }
            // lib.optionalAttrs (srv ? config) {
              initialization_options = srv.config;
            }
          )
        ) helixServers;

        derivedLanguages = builtins.listToAttrs (
          lib.concatMap (
            server:
            map (langName: lib.nameValuePair langName { language_servers = [ server ]; }) (
              serverLanguages.${server} or [ ]
            )
          ) (builtins.attrNames derivedLsps)
        );
      in
      {
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
          packages = [
            pkgs.gram
          ];

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
              lsp = lib.recursiveUpdate derivedLsps config.rum.programs.gram.lsps;
              languages = derivedLanguages;
              cli_default_open_behavior = "existing_window";
              helix_mode = true;
              theme = "nox-default";
              icon_theme = "Gram (Default)";
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
