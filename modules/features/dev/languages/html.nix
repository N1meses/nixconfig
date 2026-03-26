{...}: {
  flake.modules.homeManager.html = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.vscode-langservers-extracted
    ];
  };
}
