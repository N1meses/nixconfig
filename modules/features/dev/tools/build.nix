_: {
  aspects.build.home = {pkgs, ...}: {
    home.packages = with pkgs; [gnumake cmake pkg-config];
  };
}
