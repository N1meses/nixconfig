_: {
  aspects.hardwareNimeses.finix =
    { pkgs, ... }:
    {
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "uas"
        "sd_mod"
        "btrfs"
      ];
      boot.kernelModules = [ "kvm-amd" ];

      boot.kernelParams = [
        "amd_pstate=active"
        "amdgpu.ppfeaturemask=0xffffffff"
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libva
        ];
      };

      hardware.firmware = [ pkgs.linux-firmware ];

      environment.variables = {
        AMD_VULKAN_ICD = "RADV";
        LIBVA_DRIVER_NAME = "radeonsi";
      };
    };
}
