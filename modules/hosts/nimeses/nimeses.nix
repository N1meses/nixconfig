{
  config,
  inputs,
  ...
}:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [
      "libvirtd"
      "kvm"
    ];
    aspects = with config.aspectLib.names; [
      workstation
      diskoNimeses
      hardwareNimeses
      cachyosKernel
      laptop
      airvpn
      python
      c
      rust
      markdown
      direnv
      cli
      music
      sops
    ];

    nixosModule =
      {
        pkgs,
        config,
        ...
      }:
      {
        imports = [
          inputs.disko.nixosModules.disko
        ];

        sops = {
          age.keyFile = "/home/nimeses/.config/sops/age/keys.txt";
          secrets.nimeses-password.neededForUsers = true;
        };

        users.users.nimeses.hashedPasswordFile = config.sops.secrets.nimeses-password.path;

        boot.kernelPackages = pkgs.linuxPackages_latest;
      };

    homeModule = { pkgs, ... }: {
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
            "XF86AudioRaiseVolume" = {
              spawn = mkNoctaliaNiri "volume-up";
            };
            "XF86AudioLowerVolume" = {
              spawn = mkNoctaliaNiri "volume-down";
            };
            "XF86AudioMute" = {
              spawn = mkNoctaliaNiri "volume-mute";
            };
            "XF86MonBrightnessUp" = {
              spawn = mkNoctaliaNiri "brightness-up";
            };
            "XF86MonBrightnessDown" = {
              spawn = mkNoctaliaNiri "brightness-down";
            };

            "XF86AudioPlay" = {
              spawn = mkNoctaliaNiri "media toggle";
            };
            "XF86AudioNext" = {
              spawn = mkNoctaliaNiri "media next";
            };
            "XF86AudioPrev" = {
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
            "Print" = {
              spawn = mkNoctaliaNiri "screenshot-fullscreen";
            };
            "Mod+Print" = {
              spawn = mkNoctaliaNiri "screenshot-region";
            };
          };
        };
      };

      packages = with pkgs; [
        antigravity-cli
        claude-code
        vesktop
        element-desktop
        sops
        obsidian
        tor-browser
        mpv
        nicotine-plus
        rmpc
        inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
