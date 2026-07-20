{ config, ... }: {
  aspects.workstation.includes = with config.aspectLib.names; [
    base
    cliEnv
    desktop
    niri
    ly
    nix
    nixIndex
    zed
    kitty
  ];
}
