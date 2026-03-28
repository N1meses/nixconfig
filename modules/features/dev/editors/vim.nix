{...}: {
  flake.modules.homeManager.vim = {config, lib, ...}: {
    options.features.dev.editors.vim.enable = lib.mkEnableOption "vim editor";

    config = lib.mkIf config.features.dev.editors.vim.enable {
      programs.vim.enable = true;
    };
  };
}
