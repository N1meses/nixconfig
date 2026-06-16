{...}: {
  flake.modules.finix.hardwareIcarus = {pkgs, ...}: {
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "thunderbolt"
    ];

    boot.kernelParams = ["random.trust_cpu=on" "random.trust_bootlaoder=on"];

    hardware = {
      graphics.extraPackages = [ pkgs.intel-media-driver ];
      graphics.extraPackages32 = [ pkgs.pkgsi686Linux.intel-media-driver ];

      firmware = [pkgs.linux-firmware];
    };
  };
}
