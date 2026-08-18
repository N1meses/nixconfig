{ config, ... }: {
  aspects.server.media.ocis = {
    description = "ownCloud Infinite Scale.";
    includes = with config.aspectLib.names; [
      server.nginx
      server.security.restic
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
        ocisUrl = "https://cloud.${cfg.domain}";
        issuer = "https://auth.${cfg.domain}/application/o/ocis/";
      in
      {
        services.ocis = {
          enable = true;
          address = "127.0.0.1";
          port = 9200;
          url = ocisUrl;

          environment = {
            OCIS_URL = ocisUrl;
            OCIS_LOG_LEVEL = "debug";
            OCIS_INSECURE = "false";
            PROXY_TLS = "false";

            OCIS_OIDC_ISSUER = issuer;
            OCIS_EXCLUDE_RUN_SERVICES = "idp";
            WEB_OIDC_CLIENT_ID = "ocis";
            WEB_OIDC_SCOPE = "openid profile email roles";
            PROXY_OIDC_REWRITE_WELLKNOWN = "true";
            PROXY_AUTOPROVISION_ACCOUNTS = "true";
            PROXY_USER_OIDC_CLAIM = "preferred_username";
            PROXY_USER_CS3_CLAIM = "username";
            PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";

            THUMBNAILS_MAX_CONCURRENT_REQUESTS = "50";
            THUMBNAILS_RESOLUTION_LIMIT = "50000000";
          };
        };

        services.nginx.appendHttpConfig = ''
          map $request_uri $limit_image_req {
            default "";
            "~*\.(jpg|jpeg|png|gif|heic|webp|bmp|tiff)(\?|$)" $binary_remote_addr;
          }
          limit_req_zone $limit_image_req zone=ocis_images:10m rate=30r/s;
        '';

        services.nginx.virtualHosts."cloud.${cfg.domain}".locations."/" = {
          proxyPass = "http://127.0.0.1:9200";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 0;
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_read_timeout 120s;
            proxy_set_header X-Forwarded-Proto https;
            limit_req zone=ocis_images burst=500;
          '';
        };

        services.restic.backups.system.paths = [ "/var/lib/ocis" ];
      };
  };
}
