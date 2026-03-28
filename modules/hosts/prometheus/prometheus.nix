{
  config,
  lib,
  ...
}: let
  mkNoctalia = cmd:
    ["noctalia-shell" "ipc" "call"]
    ++ (lib.splitString " " cmd);
in {
  registry.hosts.prometheus = {
    username = "prometheus";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["gamemode" "libvirtd" "kvm"];
  };

  configurations.nixos.prometheus.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardwarePrometheus
      common
      desktop
      gaming
      performance
      virtualisation
    ];

    features.services = {
      audio.enable = true;
      bluetooth.enable = true;
      greetd.enable = true;
    };

    networking = {
      hostName = "prometheus";
      interfaces.eno1.wakeOnLan.enable = true;
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
      };
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

    services.tailscale.enable = true;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

    environment = {
      variables.QT_QPA_PLATFORMTHEME = "qt6ct";
      systemPackages = with pkgs; [wol ethtool ntfs3g git wget];
    };
  };

  configurations.homeManager.prometheus.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      common
      dev
      desktop
    ];

    features = {
      apps = {
        ghostty.enable = true;
        yazi.enable = true;
        gtk.enable = true;
        nh.enable = true;
        fastfetch.enable = true;
        browser = {
          enable = true;
          brave.enable = true;
          defaultBrowser = "brave";
        };
      };

      desktop.noctalia.enable = true;

      dev = {
        editors = {
          helix.enable = true;
          zed.enable = true;
          defaultEditor = "helix";
        };
        tools.opencode.enable = true;
      };

      services.user = {
        gnomeKeyring.enable = true;
        security.gpg-agent.enable = true;
        storage.udiskie.enable = true;
      };

      compositors = {
        niri.enable = true;
        hyprland.enable = true;

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
          "F10".action.spawn = mkNoctalia "volume increase";
          "F9".action.spawn = mkNoctalia "volume decrease";
          "F5".action.spawn = mkNoctalia "volume muteOutput";

          "F7".action.spawn = mkNoctalia "media playPause";
          "F8".action.spawn = mkNoctalia "media next";
          "F6".action.spawn = mkNoctalia "media previous";

          "Mod+Shift+q".action.spawn = mkNoctalia "lockScreen lock";
          "Mod+n".action.spawn = mkNoctalia "launcher toggle";
          "Mod+b".action.spawn = mkNoctalia "bar toggle";

          "F12".action.spawn = ["sh" "-c" "grim - | wl-copy"];
          "Shift+F12".action.spawn = ["sh" "-c" "grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
          "Mod+F12".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"];
          "Mod+Shift+F12".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
        };

        hyprland.extraBinds = [
          ", F10, exec, noctalia-shell ipc call volume increase"
          ", F9, exec, noctalia-shell ipc call volume decrease"
          ", F5, exec, noctalia-shell ipc call volume muteOutput"

          ", F7, exec, noctalia-shell ipc call media playPause"
          ", F8, exec, noctalia-shell ipc call media next"
          ", F6, exec, noctalia-shell ipc call media previous"

          "SUPERSHIFT, Q, exec, noctalia-shell ipc call lockScreen lock"
          "SUPER, N, exec, noctalia-shell ipc call launcher toggle"
          "SUPER, B, exec, noctalia-shell ipc call bar toggle"

          ",F12, exec, grim - | wl-copy"
          "SHIFT, F12, exec, grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
          "SUPER, F12, exec, grim -g \"$(slurp)\" - | wl-copy"
          "SUPERSHIFT, F12, exec, grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ];
      };
    };

    programs.noctalia-shell.settings.bar.position = "top";

    home.sessionVariables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
      QT_SCALE_FACTOR = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      DXVK_HDR = "1";
      ENABLE_VKBASALT = "1";
      TERMCMD = "ghostty -e";
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
    };

    home.packages = with pkgs; [
      btop
      cbonsai
      croc
      cmatrix
      trash-cli
      imv
      grim
      todo-txt-cli
      nom
      nvd
      nix-tree
      tldr
      vulnix
      qt6.qtdeclarative
      matugen
      adw-gtk3
      nwg-look
      gnome-themes-extra
      gucharmap
      glib
      vesktop
      libreoffice-qt6-fresh
      gimp
      zathura
      file-roller
      ckb-next
    ];
  };
}
