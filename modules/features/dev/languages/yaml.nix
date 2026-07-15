_: {
  aspects.yaml.home = {pkgs, ...}: {
    home.packages = with pkgs; [yaml-language-server yamlfmt];
    programs.helix.languages = {
      language-server.yaml-language-server = {
        command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
        args = ["--stdio"];
      };
      language = [
        {
          name = "yaml";
          auto-format = true;
          language-servers = ["yaml-language-server"];
        }
      ];
    };
  };
}
