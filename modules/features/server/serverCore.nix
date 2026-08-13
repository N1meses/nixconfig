_: {
  aspects.serverCore.description = "Server baseline: fail2ban, trimmed documentation and headless defaults.";
  aspects.serverCore.nixos =
    {
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        networking.firewall.enable = lib.mkDefault true;

        services.udev.packages = [ pkgs.libfido2 ];
        users.groups.plugdev = { };

        users.groups.media.gid = lib.mkForce 989;
        systemd.tmpfiles.rules = [
          "d /media 0775 root media - -"
        ];

        services.logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchDocked = "ignore";
          HandleLidSwitchExternalPower = "ignore";
        };

        services.fail2ban = {
          enable = true;
          maxretry = 5;
          bantime = "1h";
          bantime-increment = {
            enable = true;
            multipliers = "1 2 4 8 16 32 64";
            maxtime = "168h";
          };
        };

        documentation.enable = lib.mkDefault false;
        documentation.nixos.enable = lib.mkDefault false;

        environment.systemPackages = with pkgs; [
          htop
          tmux
          rsync
        ];
      };
    };
}
