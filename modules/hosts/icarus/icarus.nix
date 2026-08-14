{
  config,
  inputs,
  ...
}:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  registry.hosts.icarus = {
    machineModules = [
      ./_hardware.nix
      ./_disko.nix
      ../../features/finix/_impermanence.nix
    ];
    users = with config.registry.userNames; [ icarus ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.aspectLib.names; [
      bundle.base
      bundle.desktop
      desktop.compositors.niri
      desktop.services.ly
      profile.laptop
      server.sshd
      finix.doas
      finix.session
      finix.devUdev
      finix.netNM
      finix.seatElogind
    ];

    finixModule = { pkgs, ... }: {
      programs.resolvconf.enable = true;

      users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";

      users.groups.yubikey = { };

      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/70-fido2.rules" ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", GROUP="yubikey", MODE="0660"
        '')
      ];
    };

    homeModule =
      {
        lib,
        ...
      }:
      let
        flakeRoot = inputs.self;
      in
      {
        noctalia.settings.wallpaper = {
          directory = "${flakeRoot}/assets/icons";
          default.path = "${flakeRoot}/assets/icons/wallpaper.jpg";
          last.path = "${flakeRoot}/assets/icons/wallpaper.jpg";
          monitors = [ ];
        };

        features.compositors = {
          monitors = {
            eDP-1 = {
              resolution = {
                width = 1920;
                height = 1080;
              };
              refreshRate = 60.0;
              scale = 1.0;
              position = {
                x = 0;
                y = 0;
              };
            };
          };
          niri.extraBinds = {
            "Mod+Shift+q" = {
              spawn = mkNoctaliaNiri "session lock";
            };
            "Mod+n" = {
              spawn = mkNoctaliaNiri "panel-toggle launcher";
            };
            "Mod+b" = {
              spawn = mkNoctaliaNiri "bar-toggle";
            };

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
            "XF86Display" = {
              spawn = mkNoctaliaNiri "screenshot-fullscreen";
            };
            "Mod+XF86Display" = {
              spawn = mkNoctaliaNiri "screenshot-region";
            };
          };
          autoStart = [
            "pipewire 2>&1 & sleep 0.5; wireplumber 2>&1 & sleep 0.5; pipewire-pulse 2>&1 &"
          ];
        };
      };
  };

  fleet.icarus.home.ssh.matchBlocks.icarus = {
    hostname = "100.73.123.19";
    user = "icarus";
  };

  diskoConfigurations.icarus.disko.devices = import ./_devices.nix;
}
