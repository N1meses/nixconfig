{...}: {
  flake.modules.homeManager.c = {pkgs, ...}: {
    home.packages = with pkgs; [
      clang-tools
      ccls
      gcc
    ];
  };
}
