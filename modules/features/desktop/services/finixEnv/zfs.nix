_: {
  aspects.zfs.description = "ZFS filesystem support in initrd and the running system.";
  aspects.zfs.finix = _: {
    config = {
      boot.initrd.supportedFilesystems.zfs.enable = true;
      boot.supportedFilesystems.zfs.enable = true;
    };
  };
}
