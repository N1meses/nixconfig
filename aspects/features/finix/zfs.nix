_: {
  aspects.finix.zfs = {
    description = "ZFS filesystem support in initrd and the running system.";
    finix = _: {
      config = {
        boot.initrd.supportedFilesystems.zfs.enable = true;
        boot.supportedFilesystems.zfs.enable = true;
      };
    };
  };
}
