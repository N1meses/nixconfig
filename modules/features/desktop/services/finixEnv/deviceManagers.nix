_: {
  aspects.devUdev.description = "Selects udev as the device manager.";
  aspects.devUdev.finix = _: { services.udev.enable = true; };
  aspects.devMdevd.description = "Selects mdevd as the device manager.";
  aspects.devMdevd.finix =
    { lib, pkgs, ... }:
    {
      services.mdevd.enable = true;
      services.mdevd.nlgroups = 4;
      finit.services.mdevd.path = lib.mkBefore [ pkgs.kmod ];
    };
  aspects.devGardendevd.description = "Selects gardendevd as the device manager.";
  aspects.devGardendevd.finix = _: { services.gardendevd.enable = true; };
}
