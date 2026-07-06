_: {
  flake.modules = {
    nixos.bluetooth = _: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
    };
    finix.bluetooth = {modules, lib, ...}: {
      imports = [
        modules.bluetooth
      ];
      services.bluetooth = {
        enable = true;
        settings.Policy.AutoEnable = lib.mkDefault true;
      };
    };
  };
}
