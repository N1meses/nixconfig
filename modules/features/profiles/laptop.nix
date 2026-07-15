_: {
  aspects.laptop = {
    nixos = {lib, ...}: {
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

    finix = {
      config,
      lib,
      modules,
      ...
    }: {
      imports = [
        modules.power-profiles-daemon
        modules.upower
        modules.acpid
        modules.zzz
        modules.thermald
        modules.brightnessctl
      ];

      services = {
        power-profiles-daemon.enable = lib.mkDefault true;
        power-profiles-daemon.extraGroups =
          lib.optionals (!config.services.elogind.enable) [config.services.seatd.group];
        upower.enable = lib.mkDefault true;
        thermald.enable = lib.mkDefault true;
        acpid = {
          enable = lib.mkDefault true;
          handlers.lid = {
            event = "button/lid.*";
            action = ''
              grep -q closed /proc/acpi/button/lid/LID*/state \
                && ${lib.getExe config.programs.zzz.package}
            '';
          };
        };
      };

      programs.brightnessctl.enable = lib.mkDefault true;
      programs.zzz.enable = lib.mkDefault true;
    };
  };
}
