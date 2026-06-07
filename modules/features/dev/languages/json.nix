{...}: {
  flake.modules.homeManager.json = {pkgs, ...}: {
    home.packages = with pkgs; [nodePackages.vscode-langservers-extracted];
    programs.helix.languages = {
      language-server.vscode-json-languageserver = {
        command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-json-languageserver";
        args = ["--stdio"];
      };
      language = [
        {
          name = "json";
          auto-format = true;
          language-servers = ["vscode-json-languageserver"];
        }
      ];
    };
  };
}
