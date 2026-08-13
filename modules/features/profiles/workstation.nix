{ config, ... }: {
  aspects.workstation.description = "Full graphical workstation: base plus CLI environment, desktop, niri, display manager and editors.";
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
