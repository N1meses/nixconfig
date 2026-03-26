{...}: {
  flake.modules.homeManager.vim = {lib, ...}: {
    programs.vim.enable = true;
    home.sessionVariables.EDITOR = lib.mkDefault "vim";
  };
}
