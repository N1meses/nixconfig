{...}: {
  flake.modules.nixos.hardwareNimeses = {
    inputs,
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.hardware.nixosModules.framework-13-7040-amd
    ];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "uas" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/mapper/luks-9138527c-4bc6-4e65-a957-4efe286cba2b";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."luks-9138527c-4bc6-4e65-a957-4efe286cba2b" = {
      device = "/dev/disk/by-uuid/9138527c-4bc6-4e65-a957-4efe286cba2b";
      allowDiscards = true;
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/2BEA-51FC";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/vm" = {
      device = "/dev/disk/by-uuid/ce16818f-91c8-42a7-90e3-7cad0a262a08";
      fsType = "ext4";
    };

    swapDevices = [
      {
        device = "/var/swapfile";
        size = 32 * 1024;
      }
    ];

    # AMD 7040 specific optimizations for gaming
    boot.kernelParams = [
      "amd_pstate=active"
      "amdgpu.ppfeaturemask=0xffffffff"
    ];

    # Firmware updates (Framework BIOS updates via fwupd)
    services.fwupd.enable = true;

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      LIBVA_DRIVER_NAME = "radeonsi";
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        libva
      ];
    };
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.enableRedistributableFirmware = true;
  };
}
