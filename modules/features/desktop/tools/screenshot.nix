_: {
  aspects.screenshot.home = {pkgs, ...}: {
    packages = with pkgs; [
      grim
      slurp
    ];
  };
}
