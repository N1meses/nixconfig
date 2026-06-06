{config, ...}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
  mkNoctaliaHypr = config.flake.lib.mkNoctaliaHypr;
  mkNoctaliaMango = config.flake.lib.mkNoctaliaMango;
in {
  registry.hosts.prometheus = {
    username = "prometheus";
    system = "x86_64-linux";
    stateVersion = "25.05";
    homeDirectory = "/home/prometheus";
    extraGroups = ["gamemode" "libvirtd" "kvm"];
  };

  configurations.nixos.prometheus.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardwarePrometheus
      users
      core
      base
      shell
      desktop
      gaming
      performance
      tailscale
      niri
      hyprland
      mango
      virtualisation
    ];

    networking = {
      hostName = "prometheus";
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

  configurations.homeManager.prometheus.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      core
      shell
      desktop
      helix
      zed
      git
      niri
      hyprland
      mango
      nix
      c
    ];

    programs.git.settings.user = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };

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
          "F10" = {spawn = mkNoctaliaNiri "volume increase";};
          "F9" = {spawn = mkNoctaliaNiri "volume decrease";};
          "F5" = {spawn = mkNoctaliaNiri "volume-mute";};

          "F7" = {spawn = mkNoctaliaNiri "media toggel";};
          "F8" = {spawn = mkNoctaliaNiri "media next";};
          "F6" = {spawn = mkNoctaliaNiri "media previous";};

          "Mod+Shift+q" = {spawn = mkNoctaliaNiri "lockScreen lock";};
          "Mod+n" = {spawn = mkNoctaliaNiri "launcher toggle";};
          "Mod+b" = {spawn = mkNoctaliaNiri "bar toggle";};
        };

        mango.extraBinds = [
          "NONE, F10, ${mkNoctaliaMango "volume increase"}"
          "NONE, F9, ${mkNoctaliaMango "volume decrease"}"
          "NONE, F5, ${mkNoctaliaMango "volume-mute"}"

          "NONE, F7, ${mkNoctaliaMango "media toggel"}"
          "NONE, F8, ${mkNoctaliaMango "media next"}"
          "NONE, F6, ${mkNoctaliaMango "media previous"}"

          "SUPER+SHIFT, Q, ${mkNoctaliaMango "lockScreen lock"}"
          "SUPER, N, ${mkNoctaliaMango "launcher toggle"}"
          "SUPER, B, ${mkNoctaliaMango "bar toggle"}"
        ];

        hyprland.extraBinds = [
          ", F10, ${mkNoctaliaHypr "volume increase"}"
          ", F9, ${mkNoctaliaHypr "volume decrease"}"
          ", F5, ${mkNoctaliaHypr "volume-mute"}"

          ", F7, ${mkNoctaliaHypr "media toggel"}"
          ", F8, ${mkNoctaliaHypr "media next"}"
          ", F6, ${mkNoctaliaHypr "media previous"}"

          "SUPERSHIFT, Q, ${mkNoctaliaHypr "session lock"}"
          "SUPER, N, ${mkNoctaliaHypr "panel-toggel launcher"}"
          "SUPER, B, ${mkNoctaliaHypr "bar-toggle"}"
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
}
