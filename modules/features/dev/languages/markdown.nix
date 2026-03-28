{...}: {
  flake.modules.homeManager.markdown = { pkgs, ... }: {
    home.packages = with pkgs; [ marksman nodePackages.markdownlint-cli ];
    programs.helix.languages = {
      language-server.marksman = {
        command = "${pkgs.marksman}/bin/marksman";
        args = [ "server" ];
      };
      language = [{
        name = "markdown";
        auto-format = true;
        language-servers = [ "marksman" ];
      }];
    };
  };
}
