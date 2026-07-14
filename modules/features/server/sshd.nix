_: {
  flake.modules = {
    nixos.sshd = {
      lib,
      config,
      ...
    }: let
      cfg = config.features.server;
    in {
      options.features.server = {
        sshPort = lib.mkOption {
          type = lib.types.int;
          default = 22;
          description = "Port for the SSH daemon";
        };

        allowedUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "allowed user for ssh";
        };
      };

      config = {
        services.openssh = {
          enable = true;
          ports = [cfg.sshPort];
          settings =
            {
              PermitRootLogin = lib.mkDefault "no";
              PasswordAuthentication = lib.mkDefault false;
              AcceptEnv = ["TERM"];
            }
            // lib.optionalAttrs (cfg.allowedUsers != []) {
              AllowUsers = cfg.allowedUsers;
            };
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [cfg.sshPort];

        services.fail2ban.jails.sshd.settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 3;
          bantime = "24h";
        };
      };
    };
    finix.sshd = {
      modules,
      lib,
      ...
    }: {
      imports = [modules.openssh];
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = lib.mkDefault false;
          PermitRootLogin = lib.mkDefault "no";
          KbdInteractiveAuthentication = lib.mkDefault false;
        };
      };
    };
  };
}
