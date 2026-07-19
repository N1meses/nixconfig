_: {
  aspects.hardwareAthena.nixos =
    {
      lib,
      pkgs,
      ...
    }:
    {
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      boot.initrd.kernelModules = [ "i915" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      boot.kernelParams = [
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
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [ intel-media-driver ];
      };

      hardware.enableRedistributableFirmware = true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
    };
}
