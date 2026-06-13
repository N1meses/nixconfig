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

    hardware.firmware = [pkgs.linux-firmware];
  };
}
