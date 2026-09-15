_: {
  aspects.desktop.tools.screenshot = {
    description = "Screenshot and screen-recording tools.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        grim
        slurp
      ];
    };
  };
}
