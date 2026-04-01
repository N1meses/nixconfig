{config, ...}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
  mkNoctaliaHypr = config.flake.lib.mkNoctaliaHypr;
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
      users
      core
      base
      shell
      desktop
      gaming
      performance
      virtualisation
      tailscale
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
      opencode
      git
    ];

    features = {
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
          "F10".action.spawn = mkNoctaliaNiri "volume increase";
          "F9".action.spawn = mkNoctaliaNiri "volume decrease";
          "F5".action.spawn = mkNoctaliaNiri "volume muteOutput";

          "F7".action.spawn = mkNoctaliaNiri "media playPause";
          "F8".action.spawn = mkNoctaliaNiri "media next";
          "F6".action.spawn = mkNoctaliaNiri "media previous";

          "Mod+Shift+q".action.spawn = mkNoctaliaNiri "lockScreen lock";
          "Mod+n".action.spawn = mkNoctaliaNiri "launcher toggle";
          "Mod+b".action.spawn = mkNoctaliaNiri "bar toggle";

          "F12".action.spawn = ["sh" "-c" "grim - | wl-copy"];
          "Shift+F12".action.spawn = ["sh" "-c" "grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
          "Mod+F12".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"];
          "Mod+Shift+F12".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
        };

        hyprland.extraBinds = [
          ", F10, ${mkNoctaliaHypr "volume increase"}"
          ", F9, ${mkNoctaliaHypr "volume decrease"}"
          ", F5, ${mkNoctaliaHypr "volume muteOutput"}"

          ", F7, ${mkNoctaliaHypr "media playPause"}"
          ", F8, ${mkNoctaliaHypr "media next"}"
          ", F6, ${mkNoctaliaHypr "media previous"}"

          "SUPERSHIFT, Q, ${mkNoctaliaHypr "lockScreen lock"}"
          "SUPER, N, ${mkNoctaliaHypr "launcher toggle"}"
          "SUPER, B, ${mkNoctaliaHypr "bar toggle"}"

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
