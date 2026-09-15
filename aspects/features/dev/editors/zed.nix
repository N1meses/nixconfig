{ inputs, ... }: {
  aspects.dev.editors.zed = {
    description = "The Zed editor, set as $VISUAL, themed with nox-default.";
    home = { pkgs, lib, ... }: {
      environment.sessionVariables.VISUAL = "zeditor --wait";

      rum.programs.zed = {
        enable = true;
        package = pkgs.zed-editor-fhs;

        themes.nox-default = import "${inputs.self}/assets/themes/nox/to-zed.nix";

        settings = {
          theme = lib.mkDefault "nox-default";
          telemetry.metrics = false;

          cli_default_open_behavior = "existing_window";
          helix_mode = true;
          icon_theme = "Zed (Default)";
          ui_font_size = 18.0;
          buffer_font_size = 18.0;
        };
      };
    };
  };
}
