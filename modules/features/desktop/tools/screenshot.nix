_: {
  aspects.screenshot.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      grim
      slurp
    ];
  };
}
