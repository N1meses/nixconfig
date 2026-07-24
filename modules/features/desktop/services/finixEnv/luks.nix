_: {
  aspects.luks.finix = _: {
    boot.initrd.supportedFilesystems.luks.enable = true;
    boot.supportedFilesystems.luks.enable = true;
  };
}
