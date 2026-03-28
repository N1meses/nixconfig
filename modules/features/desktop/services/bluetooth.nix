{...}: {
  flake.modules.nixos.bluetooth = {config, lib, ...}: {
    options.features.services.bluetooth.enable = lib.mkEnableOption "bluetooth";

    config = lib.mkIf config.features.services.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
    };
  };
}
