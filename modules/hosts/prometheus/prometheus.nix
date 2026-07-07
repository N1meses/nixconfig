{config, ...}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
  mkNoctaliaMango = config.flake.lib.mkNoctaliaMango;
in {
  registry.hosts.prometheus = {
    username = "prometheus";
    system = "x86_64-linux";
    stateVersion = "25.05";
    homeDirectory = "/home/prometheus";
    extraGroups = ["gamemode" "libvirtd" "kvm"];
    aspects = with config.flake.lib.aspects; [
      workstation
      hardwarePrometheus
      cachyosKernel
      mango
      gaming
      performance
      virtualisation
      c
      python
      rust
      markdown
      cli
      build
      direnv
    ];

    nixosModule = {pkgs, ...}: {
      networking = {
        interfaces.eno1.wakeOnLan.enable = true;
        firewall.enable = true;
        networkmanager.dispatcherScripts = [
          {
            source = pkgs.writeText "wol-enable" ''
              #!/bin/sh
              if [ "$1" = "eno1" ]; then
                ${pkgs.ethtool}/bin/ethtool -s eno1 wol g
              fi
            '';
            type = "basic";
          }
        ];
      };

      hardware.enableRedistributableFirmware = true;

      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

      environment = {
        variables.QT_QPA_PLATFORMTHEME = "qt6ct";
        systemPackages = with pkgs; [wol ethtool ntfs3g git wget];
      };
    };

    homeModule = {pkgs, ...}: {
      programs.noctalia.settings.bar.default.position = "top";

      features = {
        compositors = {
          monitors."HDMI-A-1" = {
            resolution = {
              width = 3840;
              height = 2160;
            };
            refreshRate = 119.880;
            scale = 1.2;
            transform = "0";
            vrr.enable = false;
            position = {
              x = 0;
              y = 0;
            };
          };

          niri.extraBinds = {
            "F10" = {spawn = mkNoctaliaNiri "volume-up";};
            "F9" = {spawn = mkNoctaliaNiri "volume-down";};
            "F5" = {spawn = mkNoctaliaNiri "volume-mute";};

            "F7" = {spawn = mkNoctaliaNiri "media toggle";};
            "F8" = {spawn = mkNoctaliaNiri "media next";};
            "F6" = {spawn = mkNoctaliaNiri "media previous";};

            "Mod+Shift+q" = {spawn = mkNoctaliaNiri "session lock";};
            "Mod+n" = {spawn = mkNoctaliaNiri "panel-toggle launcher";};
            "Mod+b" = {spawn = mkNoctaliaNiri "bar-toggle";};
          };

          mango.extraBinds = [
            "NONE, F10, ${mkNoctaliaMango "volume-up"}"
            "NONE, F9, ${mkNoctaliaMango "volume-down"}"
            "NONE, F5, ${mkNoctaliaMango "volume-mute"}"

            "NONE, F7, ${mkNoctaliaMango "media toggle"}"
            "NONE, F8, ${mkNoctaliaMango "media next"}"
            "NONE, F6, ${mkNoctaliaMango "media previous"}"

            "SUPER+SHIFT, Q, ${mkNoctaliaMango "session lock"}"
            "SUPER, N, ${mkNoctaliaMango "panel-toggle launcher"}"
            "SUPER, B, ${mkNoctaliaMango "bar-toggle"}"
          ];
        };
      };

      home.sessionVariables = {
        GDK_SCALE = "1";
        GDK_DPI_SCALE = "1";
        QT_SCALE_FACTOR = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
        size = 24;
      };

      programs.mpv = {
        enable = true;
        scripts = [pkgs.mpvScripts.mpris];
        config = {
          vo = "gpu-next";
          gpu-api = "vulkan";
          hwdec = "auto-copy";
        };
      };

      home.packages = with pkgs; [
        btop
        croc
        trash-cli
        grim
        nom
        nvd
        nix-tree
        adw-gtk3
        nwg-look
        gnome-themes-extra
        vesktop
        file-roller
        claude-code
        ckb-next
        element-desktop
        jellyfin-mpv-shim
        gparted
      ];
    };
  };
}
