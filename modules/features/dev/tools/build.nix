{...}: {
  flake.modules.homeManager.build = {pkgs, ...}: {
    home.packages = with pkgs; [gnumake cmake pkg-config];
  };
}
