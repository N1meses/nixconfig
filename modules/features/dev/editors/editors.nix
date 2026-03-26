{
  config,
  lib,
  ...
}: let
  cfg = config.features.dev.editors;
in {
  options.features.dev.editors = {
    helix.enable = lib.mkEnableOption "Enable the helix editor and configuration";
    zed.enable = lib.mkEnableOption "Enable the zed editor and configuration";
    vim.enable = lib.mkEnableOption "Enable the vim editor and configuration";
  };

  config = {
    flake.modules.homeManager.editors = {lib, ...}: {
      imports = with config.flake.modules.homeManager;
        []
        ++ lib.optional cfg.helix.enable helix
        ++ lib.optional cfg.zed.enable zed
        ++ lib.optional cfg.vim.enable vim;
    };
  };
}
