{...}: {
  flake.modules.homeManager.json = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.vscode-langservers-extracted
    ];
  };
}
