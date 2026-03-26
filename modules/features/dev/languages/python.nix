{...}: {
  flake.modules.homeManager.python = {pkgs, ...}: {
    home.packages = with pkgs; [
      pyright
      ruff
      python3
      uv
    ];
  };
}
