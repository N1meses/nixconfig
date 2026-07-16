_: {
  aspects.bluetooth = {
    nixos = _: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
    };

    finix =
      {
        modules,
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
  };
}
