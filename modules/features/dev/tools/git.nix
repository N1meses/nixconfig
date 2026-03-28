{...}: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    programs = {
      git.enable = true;

      delta = {
        enable = true;
        enableGitIntegration = true;
      };

      lazygit.enable = true;
    };

    home.packages = with pkgs; [
      pre-commit
      commitizen
      lefthook
      tig
      git-absorb
    ];
  };
}
