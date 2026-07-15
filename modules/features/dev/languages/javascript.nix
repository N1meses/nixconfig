_: {
  aspects.javascript.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.prettier
      nodePackages.eslint
      bun
    ];
    programs.helix.languages = {
      language-server.typescript-language-server = {
        command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
        args = ["--stdio"];
      };
      language = [
        {
          name = "javascript";
          auto-format = true;
          language-servers = ["typescript-language-server"];
        }
        {
          name = "typescript";
          auto-format = true;
          language-servers = ["typescript-language-server"];
        }
      ];
    };
  };
}
