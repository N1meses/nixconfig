{
  config,
  lib,
  ...
}: let
  cfg = config.features.dev.editors;
  desktopFile =
    {
      helix = "Helix.desktop";
      vim = "vim.desktop";
      zed = "dev.zed.Zed.desktop";
    }.${
      cfg.defaultEditor
    };
in {
  options.features.dev.editors = {
    helix.enable = lib.mkEnableOption "Enable the helix editor and configuration";
    zed.enable = lib.mkEnableOption "Enable the zed editor and configuration";
    vim.enable = lib.mkEnableOption "Enable the vim editor and configuration";

    defaultEditor = lib.mkOption {
      type = lib.types.enum ["helix" "zed" "vim"];
      default = "helix";
      description = "The default editor to use";
    };
  };

  config = {
    flake.modules.homeManager.editors = {lib, ...}: {
      imports = with config.flake.modules.homeManager;
        []
        ++ lib.optional cfg.helix.enable helix
        ++ lib.optional cfg.zed.enable zed
        ++ lib.optional cfg.vim.enable vim;

      home.sessionVariables = {
        EDITOR =
          if cfg.defaultEditor == "helix"
          then "hx"
          else if cfg.defaultEditor == "zed"
          then "zeditor --wait"
          else "vim";
        VISUAL =
          if cfg.defaultEditor == "helix"
          then "hx"
          else if cfg.defaultEditor == "zed"
          then "zeditor --wait"
          else "vim";
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
