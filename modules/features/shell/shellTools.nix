_: {
  flake.modules.homeManager.shellTools = _: {
    programs = {
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      fzf.enable = true;

      ripgrep.enable = true;

      fd.enable = true;
    };
  };
}
