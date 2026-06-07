{...}: {
  flake.modules.nixos.hardwareAthena = {
    lib,
    pkgs,
    ...
  }: {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci"];
    boot.initrd.kernelModules = ["i915"];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    boot.supportedFilesystems = ["zfs"];
    boot.zfs.forceImportRoot = false;
    boot.zfs.extraPools = ["tank"];
    boot.zfs.devNodes = "/dev/disk/by-id";
    boot.kernelParams = [
      "zfs.zfs_arc_max=8589934592"
      "i915.force_probe=46d4"
      "video=efifb:off"
    ];

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
    services.sanoid = {
      enable = true;
      datasets = {
        "tank/nextcloud" = {
          hourly = 24;
          daily = 30;
          monthly = 6;
          autosnap = true;
          autoprune = true;
        };
        "tank/media" = {
          daily = 7;
          weekly = 4;
          autosnap = true;
          autoprune = true;
        };
        "tank/downloads" = {
          autosnap = false;
          autoprune = false;
        };
      };
    };

    fileSystems."/media" = {
      device = "tank/media";
      fsType = "zfs";
    };

    fileSystems."/var/lib/nextcloud" = {
      device = "tank/nextcloud/userdata";
      fsType = "zfs";
    };

    fileSystems."/var/lib/postgresql" = {
      device = "tank/nextcloud/db";
      fsType = "zfs";
    };

    fileSystems."/downloads" = {
      device = "tank/downloads";
      fsType = "zfs";
    };

    swapDevices = [
      {
        device = "/var/swapfile";
        size = 16 * 1024;
      }
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [intel-media-driver];
    };

    hardware.enableRedistributableFirmware = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  };
}
