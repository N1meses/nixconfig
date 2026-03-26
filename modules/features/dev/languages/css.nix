{...}: {
  flake.modules.homeManager.css = {pkgs, ...}: {
    home.packages = with pkgs; [
      nodePackages.vscode-langservers-extracted
    ];
  };
}
