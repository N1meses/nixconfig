{...}: {
  flake.modules.nixos.matrix = {config, ...}: let
    cfg = config.features.server;
  in {
    services.matrix-conduit = {
      enable = true;
      secretFile = config.sops.secrets."matrix-registration-token".path;

      settings.global = {
        server_name = "matrix.${cfg.domain}";
        port = 6167;
        allow_registration = false;
        allow_federation = true;
        database_backend = "rocksdb";
        enable_lightning_bolt = false;
      };
    };

    sops.secrets."matrix-registration-token" = {};

    services.nginx.virtualHosts."matrix.${cfg.domain}" = {
      locations."/_matrix" = {
        proxyPass = "http://[::1]:6167";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 100M;";
      };
      locations."= /.well-known/matrix/server".extraConfig = ''
        return 200 '{"m.server":"matrix.${cfg.domain}:443"}';
        add_header Content-Type application/json;
      '';
      locations."= /.well-known/matrix/client".extraConfig = ''
        return 200 '{"m.homeserver":{"base_url":"https://matrix.${cfg.domain}"}}';
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
    };
  };
}
