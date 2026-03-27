{config, ...}: let
  cfg = config.features.server;
in {
  flake.modules.nixos.forgejo = {...}: {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "forgejo.${cfg.domain}";
          ROOT_URL = "https://git.${cfg.domain}";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          SSH_DOMAIN = "git.${cfg.domain}";
          SSH_PORT = 2222;
          START_SSH_SERVER = false;
        };
        service.DISABLE_REGISTRATION = true;
        log.LEVEL = "Warn";
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [2222];

    services.nginx.virtualHosts."forgejo.${cfg.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 512M;";
      };
    };
  };
}
