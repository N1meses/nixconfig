{...}: {
  flake.modules.nixos.gaming = {
    pkgs,
    lib,
    ...
  }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = false;
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    programs.alvr = {
      enable = true;
      openFirewall = true;
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode Active' 'Performance optimizations enabled'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode Stopped' 'Back to normal power profile'";
        };
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = ["--force-composition" "--backend" "wayland" "--rt"];
    };

    hardware.graphics.enable32Bit = lib.mkDefault true;

    boot.kernel.sysctl = {
      "vm.max_map_count" = lib.mkForce 2147483642;
      "vm.swappiness" = lib.mkForce 10;
      "vm.vfs_cache_pressure" = lib.mkDefault 50;
      "kernel.sched_migration_cost_ns" = lib.mkDefault 5000000;
      "kernel.sched_autogroup_enabled" = lib.mkDefault 0;
    };

    powerManagement.cpuFreqGovernor = lib.mkForce "performance";
    services.power-profiles-daemon.enable = lib.mkForce false;

    boot.kernelModules = ["ntsync"];

    environment.sessionVariables = {
      PROTON_VKD3D_HEAP = "1";
      WINE_ENABLE_NTSYNC = "1";
      PROTON_FORCE_LARGE_ADDRESS_AWARE = "1";
      PROTON_USE_EAC_LINUX = 1;
    };

    services.pipewire.extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 256;
      };
    };

    environment.systemPackages = with pkgs; [
      mangohud
      goverlay
      wineWow64Packages.staging
      nvtopPackages.full
      #lutris
      #bottles
      vulkan-tools
      vulkan-validation-layers
      vulkan-loader
      winetricks
      libnotify
    ];
  };
}
