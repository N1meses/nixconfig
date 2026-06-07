{...}: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    programs = {
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
