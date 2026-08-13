_: {
  aspects.network.description = "Network diagnostic tooling.";
  aspects.network.home = { pkgs, ... }: {
    packages = with pkgs; [
      httpie
      bandwhich
    ];
  };
}
