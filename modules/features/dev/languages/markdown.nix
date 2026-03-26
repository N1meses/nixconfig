{...}: {
  flake.modules.homeManager.markdown = {pkgs, ...}: {
    home.packages = with pkgs; [
      marksman
      nodePackages.markdownlint-cli
    ];
  };
}
