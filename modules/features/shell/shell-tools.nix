{...}:
{
  flake.modules.homeManager.shell-tools = {...}: {
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
