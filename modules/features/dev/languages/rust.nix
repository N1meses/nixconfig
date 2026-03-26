{...}: {
  flake.modules.homeManager.rust = {pkgs, ...}: {
    home.packages = with pkgs; [
      rust-analyzer
      rustfmt
      clippy
      rustc
      cargo
    ];
  };
}
