_: {
  aspects.hardwareNimeses.nixos =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.hardware.nixosModules.framework-13-7040-amd
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "uas"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      swapDevices = [
        {
          device = "/var/swapfile";
          size = 32 * 1024;
        }
      ];

      boot.kernelParams = [
        "amd_pstate=active"
        "amdgpu.ppfeaturemask=0xffffffff"
      ];

      # Firmware updates (Framework BIOS updates via fwupd)
      services.fwupd.enable = true;
      networking.useDHCP = lib.mkDefault true;

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
