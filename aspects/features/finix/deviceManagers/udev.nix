_: {
  aspects.finix.deviceManagers.udev = {
    description = "Test Matrix: Selects udev as the device manager.";
    finix = _: { services.udev.enable = true; };
  };
}
