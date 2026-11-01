_: {
  aspects.profile.rescue = {
    description = "Recovery toolkit: filesystem support and repair utilities for a broken boot.";
    nixos = { pkgs, lib, ... }: {
      boot.supportedFilesystems = [
        "ntfs"
        "exfat"
        "zfs"
      ];
      # zfs is here for mounting foreign pools by hand; never force-import one at boot
      boot.zfs.forceImportRoot = lib.mkDefault false;

      environment.systemPackages = with pkgs; [
        nixos-install-tools
        disko
        cryptsetup
        parted
        gptfdisk
        dosfstools
        e2fsprogs
        ntfs3g
        exfatprogs
        util-linux
        efibootmgr
        pciutils
        usbutils
        smartmontools
        nvme-cli
        ddrescue
        testdisk
        rsync
        tmux
      ];
    };
  };
}
