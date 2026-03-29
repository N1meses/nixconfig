{...}: {
  flake.modules.nixos.ssh = {
    lib,
    config,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server.sshPort = lib.mkOption {
      type = lib.types.int;
      default = 22;
      description = "Port for the SSH daemon";
    };

    config = {
      services.openssh = {
        enable = true;
        ports = [cfg.sshPort];
        settings = {
          PermitRootLogin = lib.mkDefault "no";
          PasswordAuthentication = lib.mkDefault false;
          AcceptEnv = ["TERM"];
        };
      };

      networking.firewall.allowedTCPPorts = [cfg.sshPort];

      services.fail2ban.jails.sshd.settings = {
        enabled = true;
        port = "ssh";
        filter = "sshd";
        maxretry = 3;
        bantime = "24h";
      };
    };
  };
}
