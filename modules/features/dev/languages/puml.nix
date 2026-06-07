{...}: {
  flake.modules.homeManager.puml = {pkgs, ...}: {
    home.packages = with pkgs; [plantuml];
  };
}
