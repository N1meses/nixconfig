{ config, ... }:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  registry.hosts.bellerophon = {
    users = with config.registry.userNames; [ icarus ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.aspectLib.names; [
      base
      desktop
      niri
      ly
      laptop
      sshd
      hardwareBellerophon
      diskoBellerophon

      devMdevd
      netIwd
      seatSeatd
      coreutilsBusybox
    ];

    finixModule = { ... }: {
      programs.resolvconf.enable = true;

      users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
    };

    homeModule = { ... }: {
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

  fleet.bellerophon.home.ssh.matchBlocks.bellerophon = {
    hostname = "TODO-tailscale-ip";
    user = "icarus";
  };
}
