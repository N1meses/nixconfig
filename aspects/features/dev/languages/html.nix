_: {
  aspects.dev.languages.html = {
    description = "HTML toolchain and language-server wiring.";
    home = { pkgs, ... }: {
      packages = with pkgs; [ nodePackages.vscode-langservers-extracted ];
      rum.programs.helix.languages = {
        language-server.vscode-html-languageserver = {
          command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-html-languageserver";
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "html";
            auto-format = true;
            language-servers = [ "vscode-html-languageserver" ];
          }
        ];
      };
    };
  };
}
