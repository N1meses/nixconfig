_: {
  aspects.finix.deviceManagers.mdevd = {
    description = "Test Matrix: Selects mdevd as the device manager.";
    finix =
      { lib, pkgs, ... }:
      {
        services.mdevd.enable = true;
        services.mdevd.nlgroups = 4;
        finit.services.mdevd.path = lib.mkBefore [ pkgs.kmod ];
      };
  };
}
