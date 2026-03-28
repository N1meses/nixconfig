{ config, ... }: let
  flakeConfig = config;
in {
  flake.modules.homeManager.editors = {
    config,
    lib,
    ...
  }: {
    imports = with flakeConfig.flake.modules.homeManager; [helix zed vim];

    options.features.dev.editors.defaultEditor = lib.mkOption {
      type = lib.types.enum ["helix" "zed" "vim"];
      default = "helix";
      description = "The default editor to use for EDITOR, VISUAL and mimeApps.";
    };

    config = let
      desktopFile = {
        helix = "Helix.desktop";
        vim = "vim.desktop";
        zed = "dev.zed.Zed.desktop";
      }.${config.features.dev.editors.defaultEditor};

      editorCmd = {
        helix = "hx";
        zed = "zeditor --wait";
        vim = "vim";
      }.${config.features.dev.editors.defaultEditor};
    in {
      home.sessionVariables = {
        EDITOR = editorCmd;
        VISUAL = editorCmd;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/plain" = [desktopFile];
          "text/x-nix" = [desktopFile];
        };
      };
    };
  };
}
