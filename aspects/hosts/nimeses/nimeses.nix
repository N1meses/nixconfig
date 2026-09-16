{
  config,
  ...
}:
let
  mkNoctaliaUmbriel = config.aspectLib.mkNoctaliaUmbriel;
in
{
  hosts.nimeses = {
    description = "finix laptop on umbriel also my daily driver";
    fleet.home.ssh.matchBlocks.nimeses = {
      hostname = "100.76.77.79";
      user = "nimeses";
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
      desktop.services.ly
      profile.laptop

      finix.doas
      finix.session
      finix.deviceManagers.udev
      finix.network.networkmanager
      finix.seat.elogind
      finix.coreutils.gnu
      core.finitV5
      users.nimeses
    ];

    finix = { pkgs, ... }: {
      users.users.root.passwordFile = "/var/lib/nimeses/root.passwd";

      users.groups.yubikey = { };
      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/70-fido2.rules" ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", GROUP="yubikey", MODE="0660"
        '')
      ];

      environment.systemPackages = [ pkgs.bash ];
    };

    home = { ... }: {
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

}
