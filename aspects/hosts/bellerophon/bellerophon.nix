{ config, ... }:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  hosts.bellerophon = {
    description = "finix laptop with busybox/iwd/mdevd/seatd, part of the finix test matrix.";
    fleet.home.ssh.matchBlocks.bellerophon = {
      hostname = "100.78.140.15";
      user = "icarus";
    };
    classes = [ "finix" ];
    disko.devices = import ./_devices.nix;
    machineModules = [
      ./_hardware.nix
      ./_disko.nix
    ];
    system = "x86_64-linux";
    includes = with config.aspectLib.aspectNames; [
      bundle.base
      bundle.desktop
      desktop.compositors.niri
      desktop.services.ly
      profile.laptop
      server.sshd

      core.finitV5
      finix.doas
      finix.session
      finix.deviceManagers.mdevd
      finix.network.iwd
      finix.seat.seatd
      finix.coreutils.busybox
      users.icarus
    ];

    finix = { ... }: {
      programs.resolvconf.enable = true;

      users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    };

    home = { ... }: {
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
        };
        autoStart = [
          "pipewire 2>&1 & sleep 0.5; wireplumber 2>&1 & sleep 0.5; pipewire-pulse 2>&1 &"
        ];
      };
    };
  };

}
