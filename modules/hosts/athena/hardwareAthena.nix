{...}: {
  flake.modules.nixos.hardwareAthena = {lib, ...}: {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    boot.supportedFilesystems = ["zfs"];
    boot.zfs.forceImportRoot = false;
    boot.zfs.extraPools = ["tank"];
    boot.zfs.devNodes = "/dev/disk/by-id";
    boot.kernelParams = ["zfs.zfs_arc_max=8589934592"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/3a592180-1767-4599-9a4f-ed6fe319b124";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/5E02-7260";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    services.zfs.trim.enable = true;
    services.zfs.autoScrub.enable = true;

    swapDevices = [
      {
        device = "/var/swapfile";
        size = 16 * 1024;
      }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  };
}
