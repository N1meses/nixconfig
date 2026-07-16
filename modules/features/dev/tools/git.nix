_: {
  aspects.git.home = {pkgs, ...}: {
    rum.programs.git.settings = {
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
    };

    packages = with pkgs; [
      delta
      lazygit
      pre-commit
      lefthook
      tig
      git-absorb
    ];
  };
}
