_: {
  aspects.build.home = {pkgs, ...}: {
    packages = with pkgs; [gnumake cmake pkg-config];
  };
}
