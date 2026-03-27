{
  config,
  lib,
  ...
}: let
  cfg = config.features.server;
in {
  options.features.server.sshPort = lib.mkOption {
    type = lib.types.int;
    default = 22;
    description = "Port for the SSH daemon";
  };

  config.flake.modules.nixos.server-core = {
    lib,
    pkgs,
    ...
  }: {
    services.openssh = {
      enable = true;
      ports = [cfg.sshPort];
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault false;
        AcceptEnv = ["TERM"];
      };
    };

    networking.firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [cfg.sshPort];
    };

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

      jails = {
        sshd = {
          settings = {
            enabled = true;
            port = "ssh";
            filter = "sshd";
            maxretry = 3;
            bantime = "24h";
          };
        };

        nginx-http-auth = {
          settings = {
            enabled = true;
            port = "http,https";
            filter = "nginx-http-auth";
            maxretry = 5;
          };
        };

        nginx-botsearch = {
          settings = {
            enabled = true;
            port = "http,https";
            filter = "nginx-botsearch";
            maxretry = 2;
          };
        };
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
}
