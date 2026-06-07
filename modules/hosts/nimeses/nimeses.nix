{
  config,
  inputs,
  ...
}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
in {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports =
      [
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
      ]
      ++ (with config.flake.modules.nixos; [
        diskoNimeses
        hardwareNimeses
        users
        core
        base
        shell
        desktop
        tailscale
        laptop
        niri
        airvpn
      ]);

    sops = {
      defaultSopsFile = ../../../secrets/nimeses.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/home/nimeses/.config/sops/age/keys.txt";
    };

    users.users.nimeses.hashedPassword = "$6$Bo/x3FIcMJKIpnqD$5Txn123BHqMQOPpnE2166p2JgziMybskSBHFX6FBmjd25.mF6ElOk4KZiKEY4aq.1EXjudASi/.0nQp7Oj6fp/";

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      core
      shell
      desktop
      helix
      zed
      nix
      python
      c
      markdown
      rust
      git
      direnv
      cli
      niri
    ];

    features = {
      compositors = {
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

        niri.extraBinds = {
          "XF86AudioRaiseVolume" = {spawn = mkNoctaliaNiri "volume-up";};
          "XF86AudioLowerVolume" = {spawn = mkNoctaliaNiri "volume-down";};
          "XF86AudioMute" = {spawn = mkNoctaliaNiri "volume-mute";};
          "XF86MonBrightnessUp" = {spawn = mkNoctaliaNiri "brightness-up";};
          "XF86MonBrightnessDown" = {spawn = mkNoctaliaNiri "brightness-down";};

          "XF86AudioPlay" = {spawn = mkNoctaliaNiri "media toggel";};
          "XF86AudioNext" = {spawn = mkNoctaliaNiri "media next";};
          "XF86AudioPrev" = {spawn = mkNoctaliaNiri "media previous";};

          "Mod+Shift+q" = {spawn = mkNoctaliaNiri "session lock";};
          "Mod+n" = {spawn = mkNoctaliaNiri "panel-toggle launcher";};
          "Mod+b" = {spawn = mkNoctaliaNiri "bar-toggle";};
        };
      };
    };

    home.pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
      gtk.enable = true;
    };

    home.packages = with pkgs; [
      antigravity-cli
      claude-code
      vesktop
      element-desktop
      sops
      obsidian
      tor-browser
      mpv
      nicotine-plus
    ];
  };
}
