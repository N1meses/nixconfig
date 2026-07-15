_: {
  aspects.shellTools.home = {pkgs, ...}: {
    rum.programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    rum.programs.fzf.enable = true;
    packages = with pkgs; [ripgrep fd];
  };
}
