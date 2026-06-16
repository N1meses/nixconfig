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
    git = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };
    extraGroups = ["libvirtd" "kvm"];
    aspects = with config.flake.lib.aspects; [
      diskoNimeses
      hardwareNimeses
      users
      virtualisation
      local
      cachyosKernel
      tailscale
      laptop
      airvpn
      core
      ly
      shell
      desktop
      niri
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
    ];
  };

  configurations.nixos.nimeses.module = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.disko.nixosModules.disko
    ];

    sops = {
      defaultSopsFile = ../../../secrets/nimeses.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/home/nimeses/.config/sops/age/keys.txt";
      secrets.nimeses-password.neededForUsers = true;
    };

    users.users.nimeses.hashedPasswordFile = config.sops.secrets.nimeses-password.path;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {pkgs, ...}: {
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

          "XF86AudioPlay" = {spawn = mkNoctaliaNiri "media toggle";};
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
