{ pkgs, ... }:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "thunderbolt"
    "f2fs"
  ];
  boot.initrd.kernelModules = [ "i915" ];

  boot.kernelParams = [
    "random.trust_cpu=on"
    "random.trust_bootloader=on"
    "quiet"
    "loglevel=3"
  ];
  boot.kernel.sysctl."kernel.printk" = "3 4 1 3";

  hardware = {
    graphics.extraPackages = [ pkgs.intel-media-driver ];
    graphics.extraPackages32 = [ pkgs.pkgsi686Linux.intel-media-driver ];
    firmware = [
      pkgs.linux-firmware
      pkgs.sof-firmware
    ];
  };
}
