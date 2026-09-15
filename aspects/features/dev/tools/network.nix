_: {
  aspects.dev.tools.network = {
    description = "Network diagnostic tooling.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        httpie
        bandwhich
      ];
    };
  };
}
