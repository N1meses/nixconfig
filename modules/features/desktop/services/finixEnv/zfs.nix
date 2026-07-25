_: {
  aspects.zfs.finix = _: {
    config = {
      boot.initrd.supportedFilesystems.zfs.enable = true;
      boot.supportedFilesystems.zfs.enable = true;
    };
  };
}
