_: {
  aspects.dev.languages.yaml = {
    description = "YAML toolchain and language-server wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        yaml-language-server
        yamlfmt
      ];
      rum.programs.helix.languages = {
        language-server.yaml-language-server = {
          command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "yaml";
            auto-format = true;
            language-servers = [ "yaml-language-server" ];
          }
        ];
      };
    };
  };
}
