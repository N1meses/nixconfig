_: {
  aspects.git.home = {pkgs, ...}: {
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
      };

      lazygit.enable = true;
    };

    packages = with pkgs; [
      pre-commit
      commitizen
      lefthook
      tig
      git-absorb
    ];
  };
}
