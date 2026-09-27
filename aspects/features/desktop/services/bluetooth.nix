{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.desktop.services.bluetooth = {
    nixos = _: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
    };

    finix =
      {
        lib,
        ...
      }:
      {
        imports = [
          modules.bluetooth
        ];
        services.bluetooth = {
          enable = true;
          settings.Policy.AutoEnable = lib.mkDefault true;
        };
      };
    description = "Bluetooth stack, powered on at boot.";
  };
}
