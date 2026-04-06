{...}: {
  flake.modules.nixos.hardwarePrometheus = {
    config,
    lib,
    ...
  }: {
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/61edc440-5d0c-4777-ab5f-950064c2c8bb";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/99C8-389D";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/mnt/games" = {
      device = "/dev/disk/by-uuid/220903B921B32465";
      fsType = "ntfs-3g";
      options = ["uid=1000" "gid=100" "dmask=000" "fmask=022" "nofail"];
    };

    swapDevices = [
      {
        device = "/var/swapfile";
        size = 32 * 1024;
      }
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    environment.sessionVariables = {
      "PROTON_ENABLE_NVAPI" = "1";
      "PROTON_HIDE_NVIDIA_GPU" = "0";
    };

    environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json".text =
      builtins.toJSON {
        rules = [
          {
            pattern = {
              feature = "procname";
              matches = "niri";
            };
            profile = "Limit Free Buffer Pool On Wayland Compositors";
          }
        ];
        profiles = [
          {
            name = "Limit Free Buffer Pool On Wayland Compositors";
            settings = [
              {
                key = "GLVidHeapReuseRatio";
                value = 0;
              }
            ];
          }
        ];
      };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
