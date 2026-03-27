{
  config,
  lib,
  ...
}: let
  mkNoctalia = cmd:
    ["noctalia-shell" "ipc" "call"]
    ++ (lib.splitString " " cmd);
in {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  features = {
    compositors = {
      niri.enable = true;
      hyprland.enable = true;

      monitors."eDP-1" = {
        resolution = {
          width = 2880;
          height = 1920;
        };
        refreshRate = 120.0;
        scale = 1.6;
        transform = "0";
        vrr.enable = true;
        position = {
          x = 0;
          y = 0;
        };
      };

      animations.enable = true;
      focus.followMouse = true;

      appearance = {
        gaps = 8;
        border = {
          enable = true;
          width = 2;
        };
      };

      input.touchpad.enable = true;

      niri.extraBinds = {
        "XF86AudioRaiseVolume".action.spawn = mkNoctalia "volume increase";
        "XF86AudioLowerVolume".action.spawn = mkNoctalia "volume decrease";
        "XF86AudioMute".action.spawn = mkNoctalia "volume muteOutput";
        "XF86MonBrightnessUp".action.spawn = mkNoctalia "brightness increase";
        "XF86MonBrightnessDown".action.spawn = mkNoctalia "brightness decrease";

        "XF86AudioPlay".action.spawn = mkNoctalia "media playPause";
        "XF86AudioNext".action.spawn = mkNoctalia "media next";
        "XF86AudioPrev".action.spawn = mkNoctalia "media previous";

        "Mod+Shift+q".action.spawn = mkNoctalia "lockScreen lock";
        "Mod+n".action.spawn = mkNoctalia "launcher toggle";
        "Mod+b".action.spawn = mkNoctalia "bar toggle";

        "Print".action.spawn = ["sh" "-c" "grim - | wl-copy"];
        "Shift+Print".action.spawn = ["sh" "-c" "grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
        "Mod+Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"];
        "Mod+Shift+Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
      };

      hyprland.extraBinds = [
        ", XF86AudioRaiseVolume, exec, noctalia-shell ipc call volume increase"
        ", XF86AudioLowerVolume, exec, noctalia-shell ipc call volume decrease"
        ", XF86AudioMute, exec, noctalia-shell ipc call volume muteOutput"
        ", XF86MonBrightnessUp, exec, noctalia-shell ipc call brightness increase"
        ", XF86MonBrightnessDown, exec, noctalia-shell ipc call brightness decrease"

        ", XF86AudioPlay, exec, noctalia-shell ipc call media playPause"
        ", XF86AudioNext, exec, noctalia-shell ipc call media next"
        ", XF86AudioPrev, exec, noctalia-shell ipc call media previous"

        "SUPERSHIFT, Q, exec, noctalia-shell ipc call lockScreen lock"
        "SUPER, N, exec, noctalia-shell ipc call launcher toggle"
        "SUPER, B, exec, noctalia-shell ipc call bar toggle"

        ",Print, exec, grim - | wl-copy"
        "SHIFT, Print, exec, grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        "SUPER, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SUPERSHIFT, Print, exec, grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
      ];

      niri.autoStart = ["noctalia-shell"];
      hyprland.autoStart = ["noctalia-shell"];
    };

    apps = {
      ghostty.enable = true;
      yazi = {
        enable = true;
        terminalFilechooser.enable = true;
      };
      browser.enable = true;
      gtk.enable = true;
      nh.enable = true;
      fastfetch.enable = true;
    };

    desktop.noctalia.enable = true;

    dev = {
      editors = {
        helix.enable = true;
        zed.enable = true;
      };
      languages = {
        nix.enable = true;
        python.enable = true;
      };
      tools.ai.enable = true;
    };

    services = {
      audio.enable = true;
      bluetooth.enable = true;
      greetd.enable = true;
      user = {
        gnomeKeyring.enable = true;
        security.gpg-agent.enable = true;
        storage.udiskie.enable = true;
      };
    };
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardware-nimeses
      common
      desktop
    ];
    users.users.nimeses.initialPassword = "test";
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {...}: {
    imports = with config.flake.modules.homeManager; [
      common
      dev
      desktop
    ];

    programs.ssh.matchBlocks = {
      "hephaistos" = {
        hostname = "100.127.108.44";
        user = "hephaistos";
      };
      "prometheus" = {
        hostname = "100.93.27.90";
        user = "prometheus";
      };
      "forgejo" = {
        hostname = "100.127.108.44";
        user = "git";
        port = 2222;
      };
    };
  };
}
