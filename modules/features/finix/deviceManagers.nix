_: {
  aspects.finix.devUdev = {
    description = "Test Matrix: Selects udev as the device manager.";
    finix = _: { services.udev.enable = true; };
  };
  aspects.finix.devMdevd = {
    description = "Test Matrix: Selects mdevd as the device manager.";
    finix =
      { lib, pkgs, ... }:
      {
        services.mdevd.enable = true;
        services.mdevd.nlgroups = 4;
        finit.services.mdevd.path = lib.mkBefore [ pkgs.kmod ];
      };
  };
  aspects.finix.devGardendevd = {
    description = "Test Matrix: Selects gardendevd as the device manager.";
    finix = _: { services.gardendevd.enable = true; };
  };
}
