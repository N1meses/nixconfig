_: {
  aspects.devUdev.finix = _: { services.udev.enable = true; };
  aspects.devMdevd.finix =
    { lib, pkgs, ... }:
    {
      services.mdevd.enable = true;
      services.mdevd.nlgroups = 4;
      finit.services.mdevd.path = lib.mkBefore [ pkgs.kmod ];
    };
  aspects.devGardendevd.finix = _: { services.gardendevd.enable = true; };
}
