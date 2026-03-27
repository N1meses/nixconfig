{config, lib, ...}: let
  cfg = config.features.services;
in {
  options.features.services = {
    audio.enable = lib.mkEnableOption "pipewire audio";
    bluetooth.enable = lib.mkEnableOption "bluetooth";
    greetd.enable = lib.mkEnableOption "greetd display manager";
  };

  config.flake.modules.nixos.desktopServices = {...}: {
    imports = with config.flake.modules.nixos;
      [graphics fonts portals]
      ++ lib.optional cfg.audio.enable audio
      ++ lib.optional cfg.bluetooth.enable bluetooth
      ++ lib.optional cfg.greetd.enable greetd;
  };
}
