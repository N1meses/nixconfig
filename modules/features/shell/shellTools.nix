_: {
  aspects.shellTools.home = {pkgs, ...}: {
    rum.programs.zoxide = {
      enable = true;
      integrations.zsh.enable = true;
    };
    rum.programs.fzf = {
      enable = true;
      integrations.zsh.enable = true;
    };
    packages = with pkgs; [ripgrep fd];
  };
}
