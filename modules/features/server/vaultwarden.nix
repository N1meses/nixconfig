{...}: {
  flake.modules.nixos.vaultwarden = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server = {
      vaultwarden.enable = lib.mkEnableOption "vaultwarden password manager";
    };

    config = lib.mkIf cfg.vaultwarden.enable {
      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";

        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          DOMAIN = "https://vaultwarden.${cfg.domain}";
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

      services.nginx.virtualHosts."vaultwarden.${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
        };
      };
    };
  };
}
