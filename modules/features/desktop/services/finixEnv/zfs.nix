_: {
  aspects.zfs.finix =
    { lib, pkgs, ... }:
    {
      options.boot.zfs.package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.zfs;
      };

      config = {
        boot.initrd.supportedFilesystems.zfs.enable = true;
        boot.supportedFilesystems.zfs.enable = true;
      };
    };
}
