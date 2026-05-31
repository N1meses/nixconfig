{
  config,
  inputs,
  ...
}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
  mkNoctaliaHypr = config.flake.lib.mkNoctaliaHypr;
  mkNoctaliaMango = config.flake.lib.mkNoctaliaMango;
in {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports =
      [inputs.sops-nix.nixosModules.sops]
      ++ (with config.flake.modules.nixos; [
        hardwareNimeses
        users
        core
        base
        shell
        desktop
        tailscale
        laptop
        niri
        mango
        airvpn
      ]);

    sops = {
      defaultSopsFile = ../../../secrets/nimeses.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/home/nimeses/.config/sops/age/keys.txt";
    };

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
      mango
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

        niri.input.touchpad.enable = true;

        niri.extraBinds = {
          "XF86AudioRaiseVolume".action.spawn = mkNoctaliaNiri "volume-up";
          "XF86AudioLowerVolume".action.spawn = mkNoctaliaNiri "volume-down";
          "XF86AudioMute".action.spawn = mkNoctaliaNiri "volume-mute";
          "XF86MonBrightnessUp".action.spawn = mkNoctaliaNiri "brightness-up";
          "XF86MonBrightnessDown".action.spawn = mkNoctaliaNiri "brightness-down";

          "XF86AudioPlay".action.spawn = mkNoctaliaNiri "media toggel";
          "XF86AudioNext".action.spawn = mkNoctaliaNiri "media next";
          "XF86AudioPrev".action.spawn = mkNoctaliaNiri "media previous";

          "Mod+Shift+q".action.spawn = mkNoctaliaNiri "session lock";
          "Mod+n".action.spawn = mkNoctaliaNiri "panel-toggle launcher";
          "Mod+b".action.spawn = mkNoctaliaNiri "bar-toggle";
        };

        #        hyprland.extraBinds = [
        #          ", XF86AudioRaiseVolume, ${mkNoctaliaHypr "volume-up"}"
        #          ", XF86AudioLowerVolume, ${mkNoctaliaHypr "volume-down"}"
        #          ", XF86AudioMute, ${mkNoctaliaHypr "volume-mute"}"
        #          ", XF86MonBrightnessUp, ${mkNoctaliaHypr "brightness-up"}"
        #          ", XF86MonBrightnessDown, ${mkNoctaliaHypr "brightness-down"}"
        #
        #          ", XF86AudioPlay, ${mkNoctaliaHypr "media toggel"}"
        #          ", XF86AudioNext, ${mkNoctaliaHypr "media next"}"
        #          ", XF86AudioPrev, ${mkNoctaliaHypr "media previous"}"
        #
        #          "SUPERSHIFT, Q, ${mkNoctaliaHypr "lockScreen lock"}"
        #          "SUPER, N, ${mkNoctaliaHypr "launcher toggle"}"
        #          "SUPER, B, ${mkNoctaliaHypr "bar toggle"}"
        #
        #          ",Print, exec, grim - | wl-copy"
        #          "SHIFT, Print, exec, grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        #          "SUPER, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        #          "SUPERSHIFT, Print, exec, grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        #        ];
        mango.extraBinds = [
          "NONE,XF86AudioRaiseVolume,${mkNoctaliaMango "volume-up"}"
          "NONE,XF86AudioLowerVolume,${mkNoctaliaMango "volume-down"}"
          "NONE,XF86AudioMute,${mkNoctaliaMango "volume-mute"}"
          "NONE,XF86MonBrightnessUp,${mkNoctaliaMango "brightness-up"}"
          "NONE,XF86MonBrightnessDown,${mkNoctaliaMango "brightness-down"}"
          "NONE,XF86AudioPlay,${mkNoctaliaMango "media toggel"}"
          "NONE,XF86AudioNext,${mkNoctaliaMango "media next"}"
          "NONE,XF86AudioPrev,${mkNoctaliaMango "media previous"}"
          "SUPER+SHIFT,q,spawn,${mkNoctaliaMango "session lock"}"
          "SUPER,n,spawn,${mkNoctaliaMango "panel-toggel launcher"}"
          "SUPER,b,spawn,${mkNoctaliaMango "bar-toggle"}"
        ];
      };
    };

    home.pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
      gtk.enable = true;
    };

    home.packages = with pkgs; [
      gemini-cli
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
