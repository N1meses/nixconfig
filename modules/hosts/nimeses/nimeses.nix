{
  config,
  ...
}:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
  mkNoctaliaUmbriel = config.aspectLib.mkNoctaliaUmbriel;
in
{
  registry.hosts.nimeses = {
    machineModules = [
      ./_hardware.nix
      ./_disko.nix
    ];
    users = with config.registry.userNames; [ nimeses ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [ ];
    aspects = with config.aspectLib.names; [
      bundle.base
      bundle.desktop
      desktop.compositors.niri
      desktop.compositors.umbriel
      desktop.services.ly
      profile.laptop

      finix.doas
      finix.session
      finix.devUdev
      finix.netNM
      finix.seatElogind
      finix.coreutilsGnu
      profile.virtualisation
      core.finitV5
    ];

    finixModule = { pkgs, ... }: {
      users.users.root.passwordFile = "/var/lib/nimeses/root.passwd";

      users.groups.yubikey = { };
      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/70-fido2.rules" ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", GROUP="yubikey", MODE="0660"
        '')
      ];
    };

    homeModule = { ... }: {
      features = {
        compositors = {
          monitors."eDP-1" = {
            resolution = {
              width = 2880;
              height = 1920;
            };
            refreshRate = 60.001;
            scale = 1.8;
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
          umbriel.extraBinds = {
            "XF86AudioRaiseVolume" = mkNoctaliaUmbriel "volume-up";
            "XF86AudioLowerVolume" = mkNoctaliaUmbriel "volume-down";
            "XF86AudioMute" = mkNoctaliaUmbriel "volume-mute";
            "XF86MonBrightnessUp" = mkNoctaliaUmbriel "brightness-up";
            "XF86MonBrightnessDown" = mkNoctaliaUmbriel "brightness-down";

            "XF86AudioPlay" = mkNoctaliaUmbriel "media toggle";
            "XF86AudioNext" = mkNoctaliaUmbriel "media next";
            "XF86AudioPrev" = mkNoctaliaUmbriel "media previous";

            "Mod+Shift+q" = mkNoctaliaUmbriel "session lock";
            "Mod+n" = mkNoctaliaUmbriel "panel-toggle launcher";
            "Mod+b" = mkNoctaliaUmbriel "bar-toggle";
            "Print" = mkNoctaliaUmbriel "screenshot-fullscreen";
            "Mod+Print" = mkNoctaliaUmbriel "screenshot-region";
          };

          autoStart = [
            "pipewire 2>&1 & sleep 0.5"
            "wireplumber 2>&1 & sleep 0.5"
            "pipewire-pulse 2>&1 &"
          ];
        };
      };
    };
  };

  fleet.nimeses.home.ssh.matchBlocks.nimeses = {
    hostname = "100.76.77.79";
    user = "nimeses";
  };

  diskoConfigurations.nimeses.disko.devices = import ./_devices.nix;
}
