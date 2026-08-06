_: {
  aspects.hardwareNimeses.finix =
    { lib, pkgs, ... }:
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

      boot.kernelPackages = pkgs.linuxPackagesFor (
        pkgs.linuxKernel.kernels.linux_7_1.override {
          argsOverride = rec {
            src = pkgs.fetchurl {
              url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
              sha256 = "sha256-IqAZazy83zTcJ7d1YfTQQFhf00R+3JqzUxoax54wQec=";
            };
            version = "7.1.5";
            modDirVersion = version;
          };
        }
      );

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
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

      environment.variables = {
        AMD_VULKAN_ICD = "RADV";
        LIBVA_DRIVER_NAME = "radeonsi";
      };
    };
}
