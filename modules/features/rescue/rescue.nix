{...}: {
  # Recovery toolset for a host used as a portable rescue stick (see
  # modules/hosts/hermes/RESCUE.md for the procedure). Makes the box able to
  # mount/unlock and chroot into a downed host's disks fully offline.
  flake.modules.nixos.rescue = {pkgs, ...}: {
    # kernel drivers for mounting foreign disks (ntfs games, exfat data, etc.)
    boot.supportedFilesystems = ["ntfs" "exfat"];

    environment.systemPackages = with pkgs; [
      nixos-install-tools # nixos-enter, nixos-install
      cryptsetup # unlock LUKS targets
      parted
      gptfdisk # partition surgery
      dosfstools
      e2fsprogs
      ntfs3g
      exfatprogs # fs tools: ESP / ext4 / ntfs / exfat
      util-linux # lsblk, blkid, wipefs
      efibootmgr # repair/reorder UEFI boot entries on a rescued machine
      pciutils
      usbutils # lspci / lsusb
      smartmontools # disk health
      nvme-cli # NVMe diagnostics
      ddrescue # image failing disks
      testdisk # partition / data recovery (incl. photorec)
      rsync
      tmux # transfers + detachable sessions
      # git / helix / curl / wget already come from `core`
    ];
  };
}
