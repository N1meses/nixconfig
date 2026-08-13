{ config, ... }: {
  aspects.server.share.forgejo = {
    description = "Forgejo git forge with LFS and Actions.";
    includes = with config.aspectLib.names; [
      server.nginx
      server.security.restic
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
      in
      {
        services.forgejo = {
          enable = true;
          database.type = "sqlite3";
          lfs.enable = true;
          settings = {
            server = {
              DOMAIN = "forgejo.${cfg.domain}";
              ROOT_URL = "https://forgejo.${cfg.domain}";
              HTTP_ADDR = "127.0.0.1";
              HTTP_PORT = 3000;
              SSH_DOMAIN = "forgejo.${cfg.domain}";
              SSH_PORT = 2222;
              START_SSH_SERVER = true;
            };
            service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            log.LEVEL = "Warn";
            picture.AVATAR_MAX_FILE_SIZE = 5242880;
            actions.ENABLED = true;
          };
        };

        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2222 ];

        services.restic.backups.system.paths = [ "/var/lib/forgejo" ];

        services.nginx.virtualHosts."forgejo.${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
            extraConfig = "client_max_body_size 512M;";
          };
        };
      };
  };
}
