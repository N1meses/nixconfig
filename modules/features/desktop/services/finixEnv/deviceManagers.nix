_: {
  aspects.devUdev.finix = _: { services.udev.enable = true; };
  aspects.devMdevd.finix = _: { services.mdevd.enable = true; };
  aspects.devGardendevd.finix = _: { services.gardendevd.enable = true; };
}
