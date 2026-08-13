_: {
  aspects.screenshot.description = "Screenshot and screen-recording tools.";
  aspects.screenshot.home = { pkgs, ... }: {
    packages = with pkgs; [
      grim
      slurp
    ];
  };
}
