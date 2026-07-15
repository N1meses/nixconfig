_: {
  aspects.puml.home = {pkgs, ...}: {
    home.packages = with pkgs; [plantuml];
  };
}
