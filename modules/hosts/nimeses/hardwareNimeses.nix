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
        "quiet"
        "loglevel=3"
      ];
      boot.kernel.sysctl."kernel.printk" = "3 4 1 3";

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
