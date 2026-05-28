{...}: {
  flake.modules.homeManager.screenshot = {pkgs, ...}: {
    home.packages = with pkgs; [
      grim
      slurp
    ];
  };
}
