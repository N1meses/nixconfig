_: {
  flake.modules.homeManager.network = {pkgs, ...}: {
    home.packages = with pkgs; [httpie bandwhich];
  };
}
