{...}: {
  flake.modules.nixos.hardwareHermes = {lib, ...}: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ohci_pci"
      "ahci"
      "ata_piix"
      "usb_storage"
      "uas"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=50%" "mode=755"];
    };

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persist".neededForBoot = true;

    swapDevices = [];

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.enableRedistributableFirmware = true;
  };
}
