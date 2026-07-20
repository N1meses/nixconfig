_: {
  aspects.devUdev.finix = _: { services.udev.enable = true; };
  aspects.devMdevd.finix = _: {
    services.mdevd.enable = true;
    services.mdevd.nlgroups = 4;
  };
  aspects.devGardendevd.finix = _: { services.gardendevd.enable = true; };
}
