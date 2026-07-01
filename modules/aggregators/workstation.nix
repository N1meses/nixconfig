{config, ...}: {
  flake.aspectInclude.workstation = with config.flake.lib.aspects; [
    base
    desktop
    niri
    ly
    git
    nix
    zed
    kitty
  ];
}
