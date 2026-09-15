_: {
  aspects.finix.deviceManagers.gardendevd = {
    description = "Test Matrix: Selects gardendevd as the device manager.";
    finix = _: { services.gardendevd.enable = true; };
  };
}
