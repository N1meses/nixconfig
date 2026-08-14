{ config, ... }:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
  mkNoctaliaHypr = config.aspectLib.mkNoctaliaHypr;
in
{
  registry.hosts.prometheus = {
    machineModules = [
      ./_hardware.nix
      ../_uefi-systemd-boot.nix
    ];
    users = with config.registry.userNames; [ prometheus ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ ];
    aspects = with config.aspectLib.names; [
      bundle.base
      dev.tools.git
      desktop.services.ly
      dev.tools.nixIndex
      core.cachyosKernel
      profile.gaming
      profile.performance
      profile.virtualisation
    ];

    nixosModule = { pkgs, ... }: {
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

      boot.kernelPackages = pkgs.linuxPackages_latest;

      environment = {
        variables.QT_QPA_PLATFORMTHEME = "qt6ct";
        systemPackages = with pkgs; [
          wol
          ethtool
          ntfs3g
          git
          wget
        ];
      };
    };

    homeModule = { pkgs, ... }: {
      noctalia.settings.bar.default.position = "top";

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
            "F10" = {
              spawn = mkNoctaliaNiri "volume-up";
            };
            "F9" = {
              spawn = mkNoctaliaNiri "volume-down";
            };
            "F5" = {
              spawn = mkNoctaliaNiri "volume-mute";
            };

            "F7" = {
              spawn = mkNoctaliaNiri "media toggle";
            };
            "F8" = {
              spawn = mkNoctaliaNiri "media next";
            };
            "F6" = {
              spawn = mkNoctaliaNiri "media previous";
            };

            "Mod+Shift+q" = {
              spawn = mkNoctaliaNiri "session lock";
            };
            "Mod+n" = {
              spawn = mkNoctaliaNiri "panel-toggle launcher";
            };
            "Mod+b" = {
              spawn = mkNoctaliaNiri "bar-toggle";
            };
            "F12" = {
              spawn = mkNoctaliaNiri "screenshot-fullscreen";
            };
            "Mod+F12" = {
              spawn = mkNoctaliaNiri "screenshot-region";
            };
          };

          hyprland.extraBinds = [
            (mkNoctaliaHypr "F10" "volume-up")
            (mkNoctaliaHypr "F9" "volume-down")
            (mkNoctaliaHypr "F5" "volume-mute")

            (mkNoctaliaHypr "F7" "media toggle")
            (mkNoctaliaHypr "F8" "media next")
            (mkNoctaliaHypr "F6" "media previous")

            (mkNoctaliaHypr "SUPER + SHIFT + Q" "session lock")
            (mkNoctaliaHypr "SUPER + N" "panel-toggle launcher")
            (mkNoctaliaHypr "SUPER + B" "bar-toggle")

            (mkNoctaliaHypr "F12" "screenshot-fullscreen")
            (mkNoctaliaHypr "SUPER + F12" "screenshot-region")
          ];
        };
      };

      environment.sessionVariables = {
        GDK_SCALE = "1";
        GDK_DPI_SCALE = "1";
        QT_SCALE_FACTOR = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      rum.programs.mpv = {
        enable = true;
        scripts = [ pkgs.mpvScripts.mpris ];
        config = {
          vo = "gpu-next";
          gpu-api = "vulkan";
          hwdec = "auto-copy";
        };
      };
    };
  };

  fleet.prometheus.home.ssh.matchBlocks.prometheus = {
    hostname = "100.93.27.90";
    user = "prometheus";
  };
}
