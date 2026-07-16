_: {
  aspects.bash.home = { pkgs, ... }: {
    packages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
      shfmt
      bash
    ];
    rum.programs.helix.languages = {
      language-server.bash-language-server = {
        command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
      };
      language = [
        {
          name = "bash";
          auto-format = true;
          language-servers = [ "bash-language-server" ];
        }
      ];
    };
  };
}
