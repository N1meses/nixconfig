_: {
  aspects.dev.languages.json = {
    description = "JSON toolchain and language-server wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [ nodePackages.vscode-langservers-extracted ];
      rum.programs.helix.languages = {
        language-server.vscode-json-languageserver = {
          command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-json-languageserver";
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "json";
            auto-format = true;
            language-servers = [ "vscode-json-languageserver" ];
          }
        ];
      };
    };
  };
}
