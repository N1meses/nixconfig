{
  config,
  ...
}:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  registry.hosts.nimeses = {
    users = with config.registry.userNames; [ nimeses ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [ ];
    aspects = with config.aspectLib.names; [
      base
      desktop
      niri
      ly
      laptop
      hardwareNimeses
      diskoNimeses

      devUdev
      netNM
      seatElogind
      luks
      coreutilsGnu
      virtualisation
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

    homeModule = { pkgs, ... }: {
      features = {
        compositors = {
          monitors."eDP-1" = {
            resolution = {
              width = 2880;
              height = 1920;
            };
            refreshRate = 120.0;
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
          autoStart = [
            "pipewire 2>&1 & sleep 0.5"
            "wireplumber 2>&1 & sleep 0.5"
            "pipewire-pulse 2>&1 &"
          ];
        };
      };
    };
  };
}
