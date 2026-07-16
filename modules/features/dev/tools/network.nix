_: {
  aspects.network.home = { pkgs, ... }: {
    packages = with pkgs; [
      httpie
      bandwhich
    ];
  };
}
