{ inputs, ... }: {
  aspects.dev.editors.helix = {
    description = "The Helix editor, with theme and language-server registry.";

    wrapper =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        files = config.xdg.config.files;
        themes = lib.filterAttrs (n: _: lib.hasPrefix "helix/themes/" n) files;
        runtime = pkgs.linkFarm "helix-runtime" (
          [
            {
              name = "grammars";
              path = "${pkgs.helix.runtime}/grammars";
            }
            {
              name = "queries";
              path = "${pkgs.helix.runtime}/queries";
            }
          ]
          ++ lib.mapAttrsToList (n: f: {
            name = lib.removePrefix "helix/" n;
            path = f.source;
          }) themes
        );
      in
      {
        package = pkgs.helix-unwrapped;
        flags = [
          "-c"
          "${files."helix/config.toml".source}"
        ];
        env.HELIX_RUNTIME = "${runtime}";
      };

    home = { lib, ... }: {
      environment.sessionVariables = {
        EDITOR = "hx";
        VISUAL = lib.mkDefault "hx";
      };

      xdg.mime-apps.default-applications = {
        "text/plain" = lib.mkDefault [ "Helix.desktop" ];
        "text/x-nix" = lib.mkDefault [ "Helix.desktop" ];
      };

      rum.programs.helix = {
        enable = true;
        package = null;

        themes = import "${inputs.self}/assets/themes/nox/to-helix.nix";

        settings = {
          theme = lib.mkDefault "nox-default";
          editor = {
            line-number = lib.mkDefault "relative";
            mouse = lib.mkDefault true;
            default-yank-register = lib.mkDefault "+";
            clipboard-provider = lib.mkDefault "wayland";
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            file-picker.hidden = false;
            indent-guides.render = true;
          };

          keys.normal = {
            space.w = ":w";
            space.q = ":q";
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };
        };
      };
    };
  };
}
