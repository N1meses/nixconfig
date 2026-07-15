{config, ...}: {
  aspects.workstation.includes = with config.aspectLib.names; [
    base
    desktop
    niri
    ly
    git
    nix
    nixIndex
    zed
    kitty
  ];
}
