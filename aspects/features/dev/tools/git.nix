_: {
  aspects.dev.tools.git = {
    description = "git with delta paging and the shared commit identity.";
    home =
      { pkgs, ... }:
      {
        rum.programs.git = {
          enable = true;
          settings = {
            user = {
              name = "N1meses";
              email = "nilshasenthal@gmail.com";
            };
            core.pager = "delta";
            interactive.diffFilter = "delta --color-only";
          };
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
  };
}
