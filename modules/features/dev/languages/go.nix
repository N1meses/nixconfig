_: {
  flake.modules.homeManager.go = {pkgs, ...}: {
    home.packages = with pkgs; [gopls gotools golangci-lint go];
    programs.helix.languages = {
      language-server.gopls.command = "${pkgs.gopls}/bin/gopls";
      language = [
        {
          name = "go";
          auto-format = true;
          language-servers = ["gopls"];
        }
      ];
    };
  };
}
