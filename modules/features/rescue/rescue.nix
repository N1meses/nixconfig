_: {
  flake.modules.nixos.rescue = {pkgs, ...}: {
    boot.supportedFilesystems = ["ntfs" "exfat" "zfs"];

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
}
