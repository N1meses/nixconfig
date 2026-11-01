_: {
  aspects.server.base.core = {
    description = "Server baseline: fail2ban, trimmed documentation and headless defaults.";
    nixos =
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
            # Tailscale addresses from hosts.*.fleet.home.ssh.matchBlocks; keep in sync.
            ignoreIP = [
              "100.68.232.99" # atlas
              "100.73.123.19" # icarus
              "100.75.163.80" # athena
              "100.76.77.79" # nimeses
              "100.78.140.15" # bellerophon
              "100.93.27.90" # prometheus
            ];
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
  };
}
