_: {
  aspects.css.home = {pkgs, ...}: {
    packages = with pkgs; [nodePackages.vscode-langservers-extracted];
    rum.programs.helix.languages = {
      language-server.vscode-css-languageserver = {
        command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-css-languageserver";
        args = ["--stdio"];
      };
      language = [
        {
          name = "css";
          auto-format = true;
          language-servers = ["vscode-css-languageserver"];
        }
      ];
    };
  };
}
