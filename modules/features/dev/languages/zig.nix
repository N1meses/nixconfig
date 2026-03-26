{...}: {
  flake.modules.homeManager.zig = {pkgs, ...}: {
    home.packages = with pkgs; [
      zls
      zig
    ];
  };
}
