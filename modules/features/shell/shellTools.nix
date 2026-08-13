_: {
  aspects.shell.shellTools = {
    description = "fzf and zoxide, integrated into zsh.";
    home = { pkgs, ... }: {
      rum.programs.zoxide = {
        enable = true;
        integrations.zsh.enable = true;
      };
      rum.programs.fzf = {
        enable = true;
        integrations.zsh.enable = true;
      };
      packages = with pkgs; [
        ripgrep
        fd
      ];
    };
  };
}
