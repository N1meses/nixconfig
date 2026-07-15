_: {
  aspects.network.home = {pkgs, ...}: {
    home.packages = with pkgs; [httpie bandwhich];
  };
}
