{config, ...}: {
    aspects.matrix.nixos = {config, ...}: let
      cfg = config.features.server;
    in {
      services.matrix-tuwunel = {
        enable = true;
        settings.global = {
          server_name = "matrix.${cfg.domain}";
          port = [6167];
          allow_federation = true;
          new_user_displayname_suffix = "";
          require_auth_for_profile_requests = true;
          encryption_enabled_by_default_for_room_type = "private_chat";
          allow_public_room_directory_over_federation = false;
          forget_forced_upon_leave = true;
          well_known = {
            client = "https://matrix.${cfg.domain}";
            server = "matrix.${cfg.domain}:443";
          };
          identity_provider = [
            {
              brand = "authentik";
              client_id = "tuwunel";
              client_secret_file = config.sops.secrets."matrix-oidc-secret".path;
              callback_url = "https://matrix.${cfg.domain}/_matrix/client/unstable/login/sso/callback/tuwunel";
              issuer_url = "https://auth.${cfg.domain}/application/o/matrix/";
              trusted = true;
              registration = true;
              unique_id_fallbacks = false;
            }
          ];
        };
      };

      services.restic.backups.system.paths = ["/var/lib/tuwunel"];

      sops.secrets."matrix-oidc-secret" = {
        owner = "tuwunel";
      };

      services.nginx.virtualHosts."matrix.${cfg.domain}" = {
        locations."/_matrix" = {
          proxyPass = "http://[::1]:6167";
          proxyWebsockets = true;
          extraConfig = "client_max_body_size 100M;";
        };
        locations."/_tuwunel" = {
          proxyPass = "http://[::1]:6167";
          proxyWebsockets = true;
        };
        locations."/.well-known/openid-configuration" = {
          proxyPass = "http://[::1]:6167";
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
    aspects.matrix.includes = with config.aspectLib.names; [nginx restic sops];
}
