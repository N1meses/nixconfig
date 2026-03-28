{ config, ... }: let
  flakeConfig = config;
in {
  flake.modules.nixos.desktopServices = {...}: {
    imports = with flakeConfig.flake.modules.nixos; [
      graphics
      fonts
      portals
      audio
      bluetooth
      greetd
    ];
  };
}
