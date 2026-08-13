{ config, ... }: {
  aspects.vaultwarden.description = "Vaultwarden password manager.";
  aspects.vaultwarden.nixos =
    { config, ... }:
    let
      cfg = config.features.server;
    in
    {
      features.server.tls = true;

      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";

        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          DOMAIN = "https://${cfg.domain}/vaultwarden";
          SIGNUPS_ALLOWED = false;
          WEBSOCKET_ENABLED = true;
          LOG_LEVEL = "warn";
        };

        environmentFile = config.sops.secrets."vaultwarden-env".path;
      };

      sops.secrets."vaultwarden-env" = {
        owner = "vaultwarden";
        group = "vaultwarden";
      };

      services.vaultwarden.backupDir = "/var/backup/vaultwarden";

      services.restic.backups.system.paths = [ config.services.vaultwarden.backupDir ];

      services.nginx.virtualHosts."${cfg.domain}" = {
        addSSL = true;
        sslCertificate = "/var/lib/nginx/certs/${cfg.domain}.crt";
        sslCertificateKey = "/var/lib/nginx/certs/${cfg.domain}.key";
        locations."/vaultwarden/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
        };
      };
    };
  aspects.vaultwarden.includes = with config.aspectLib.names; [
    nginx
    restic
    sops
  ];
}
