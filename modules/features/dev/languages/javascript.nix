{...}: {
  flake.modules.homeManager.javascript = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.prettier
      nodePackages.eslint
      bun
    ];
  };
}
