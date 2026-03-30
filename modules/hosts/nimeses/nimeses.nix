{config, ...}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
  mkNoctaliaHypr = config.flake.lib.mkNoctaliaHypr;
in {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardwareNimeses
      users
      core
      base
      shell
      desktop
      gaming
      tailscale
      laptop
    ];

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
      markdown
      git
      direnv
      cli
    ];

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

        niri.input.touchpad.enable = true;

        niri.extraBinds = {
          "XF86AudioRaiseVolume".action.spawn = mkNoctaliaNiri "volume increase";
          "XF86AudioLowerVolume".action.spawn = mkNoctaliaNiri "volume decrease";
          "XF86AudioMute".action.spawn = mkNoctaliaNiri "volume muteOutput";
          "XF86MonBrightnessUp".action.spawn = mkNoctaliaNiri "brightness increase";
          "XF86MonBrightnessDown".action.spawn = mkNoctaliaNiri "brightness decrease";

          "XF86AudioPlay".action.spawn = mkNoctaliaNiri "media playPause";
          "XF86AudioNext".action.spawn = mkNoctaliaNiri "media next";
          "XF86AudioPrev".action.spawn = mkNoctaliaNiri "media previous";

          "Mod+Shift+q".action.spawn = mkNoctaliaNiri "lockScreen lock";
          "Mod+n".action.spawn = mkNoctaliaNiri "launcher toggle";
          "Mod+b".action.spawn = mkNoctaliaNiri "bar toggle";

          "Print".action.spawn = ["sh" "-c" "grim - | wl-copy"];
          "Shift+Print".action.spawn = ["sh" "-c" "grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
          "Mod+Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"];
          "Mod+Shift+Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"];
        };

        hyprland.extraBinds = [
          ", XF86AudioRaiseVolume, ${mkNoctaliaHypr "volume increase"}"
          ", XF86AudioLowerVolume, ${mkNoctaliaHypr "volume decrease"}"
          ", XF86AudioMute, ${mkNoctaliaHypr "volume muteOutput"}"
          ", XF86MonBrightnessUp, ${mkNoctaliaHypr "brightness increase"}"
          ", XF86MonBrightnessDown, ${mkNoctaliaHypr "brightness decrease"}"

          ", XF86AudioPlay, ${mkNoctaliaHypr "media playPause"}"
          ", XF86AudioNext, ${mkNoctaliaHypr "media next"}"
          ", XF86AudioPrev, ${mkNoctaliaHypr "media previous"}"

          "SUPERSHIFT, Q, ${mkNoctaliaHypr "lockScreen lock"}"
          "SUPER, N, ${mkNoctaliaHypr "launcher toggle"}"
          "SUPER, B, ${mkNoctaliaHypr "bar toggle"}"

          ",Print, exec, grim - | wl-copy"
          "SHIFT, Print, exec, grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
          "SUPER, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "SUPERSHIFT, Print, exec, grim -g \"$(slurp)\" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
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
    ];
  };
}
