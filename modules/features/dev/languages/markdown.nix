_: {
  aspects.markdown.home = { pkgs, ... }: {
    packages = with pkgs; [ marksman ];
    rum.programs.helix.languages = {
      language-server.marksman = {
        command = "${pkgs.marksman}/bin/marksman";
        args = [ "server" ];
      };
      language = [
        {
          name = "markdown";
          auto-format = true;
          language-servers = [ "marksman" ];
        }
      ];
    };
  };
}
