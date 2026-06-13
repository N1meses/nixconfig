{...}: {
  flake.modules = {
    nixos.laptop = {lib, ...}: {
      services = {
        upower.enable = lib.mkDefault true;
        thermald.enable = lib.mkDefault true;
        power-profiles-daemon.enable = lib.mkDefault true;
        libinput = {
          enable = lib.mkDefault true;
          touchpad = {
            tapping = lib.mkDefault true;
            naturalScrolling = lib.mkDefault false;
            disableWhileTyping = lib.mkDefault true;
          };
        };
      };

      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

      boot.kernel.sysctl = {
        "vm.swappiness" = lib.mkDefault 10;
        "vm.dirty_ratio" = lib.mkDefault 10;
        "vm.dirty_background_ratio" = lib.mkDefault 5;
      };

      hardware.acpilight.enable = lib.mkDefault true;
      services.acpid.enable = lib.mkDefault true;
    };

    finix.laptop = {lib, ...}: {
      services = {
        power-profiles-daemon.enable = lib.mkDefault true;
        upower.enable = lib.mkDefault true;
        acpid.enable = lib.mkDefault true;
      };
    };
  };
}
