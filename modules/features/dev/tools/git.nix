_:
let
  systemGitConfig = _: {
    environment.etc."gitconfig".text = ''
      [url "https://forgejo.nimeses.com/nimeses/"]
      insteadOf = https://github.com/N1meses/
      [url "forgejo:nimeses/"]
      pushInsteadOf = https://github.com/N1meses/
    '';
  };
in
{
  aspects.git.nixos = systemGitConfig;
  aspects.git.finix = systemGitConfig;

  aspects.git.home = { pkgs, ... }: {
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
