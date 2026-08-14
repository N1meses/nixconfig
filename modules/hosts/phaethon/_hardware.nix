{ pkgs, lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "uas"
    "usbhid"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];

  boot.kernelParams = [
    "random.trust_cpu=on"
    "random.trust_bootloader=on"
    "quiet"
    "loglevel=3"
  ];
  boot.kernel.sysctl."kernel.printk" = "3 4 1 3";

  hardware.firmware = [ pkgs.linux-firmware ];
}
