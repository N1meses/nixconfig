_: {
  flake.modules = {
    nixos.bluetooth = _: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
    };
    finix.bluetooth = {modules, ...}: {
      imports = [
        modules.bluetooth
      ];
      services.bluetooth = {
        enable = true;
        settings.Policy.AutoEnable = true;
      };
    };
  };
}
