{ config, ... }: {
  aspects.server.media.openCloud = {
    description = "openCloud aspect with collabora integration";
    includes = with config.aspectLib.names; [
      server.nginx
      server.security.restic
      core.sops
    ];

    nixos =
      { config, pkgs, ... }:
      let
        cfg = config.features.server;
        url = "https://cloud.${cfg.domain}";
        issuer = "https://auth.${cfg.domain}/application/o/opencloud/";

        csp = (pkgs.formats.yaml { }).generate "opencloud-csp.yaml" {
          directives = {
            "child-src" = [ "'self'" ];
            "connect-src" = [
              "'self'"
              "blob:"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
              "https://update.opencloud.eu/"
              "https://auth.${cfg.domain}/"
              "https://office.${cfg.domain}/"
            ];
            "default-src" = [ "'none'" ];
            "font-src" = [ "'self'" ];
            "frame-ancestors" = [ "'self'" ];
            "frame-src" = [
              "'self'"
              "blob:"
              "https://embed.diagrams.net/"
              "https://office.${cfg.domain}/"
            ];
            "img-src" = [
              "'self'"
              "data:"
              "blob:"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
            ];
            "manifest-src" = [ "'self'" ];
            "media-src" = [ "'self'" ];
            "object-src" = [
              "'self'"
              "blob:"
            ];
            "script-src" = [
              "'self'"
              "'unsafe-inline'"
            ];
            "style-src" = [
              "'self'"
              "'unsafe-inline'"
              "blob:"
            ];
          };
        };
      in
      {
        services.opencloud = {
          enable = true;
          address = "127.0.0.1";
          port = 9200;
          inherit url;

          environmentFile = config.sops.secrets."opencloud-env".path;

          environment = {
            OC_INSECURE = "false";
            PROXY_TLS = "false";
            OC_LOG_LEVEL = "debug";
            PROXY_CSP_CONFIG_FILE_LOCATION = "${csp}";
            OC_OIDC_ISSUER = issuer;
            OC_OIDC_CLIENT_ID = "opencloud";
            OC_EXCLUDE_RUN_SERVICES = "idp";
            WEB_OIDC_SCOPE = "openid profile email groups offline_access";
            PROXY_OIDC_REWRITE_WELLKNOWN = "true";
            PROXY_AUTOPROVISION_ACCOUNTS = "true";
            PROXY_USER_OIDC_CLAIM = "preferred_username";
            PROXY_USER_CS3_CLAIM = "username";
            PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
            PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "opencloud-roles";

            OC_ADD_RUN_SERVICES = "collaboration";

            COLLABORATION_APP_NAME = "CollaboraOnline";
            COLLABORATION_APP_PRODUCT = "Collabora";

            COLLABORATION_APP_ADDR = "http://127.0.0.1:9980";
            COLLABORATION_APP_INSECURE = "false";

            COLLABORATION_WOPI_SRC = "http://127.0.0.1:9300";
          };

          settings.proxy.role_assignment = {
            driver = "oidc";
            oidc_role_mapper = {
              role_claim = "opencloud-roles";
              role_mapping = [
                {
                  role_name = "admin";
                  claim_value = "app-opencloud-admin";
                }
                {
                  role_name = "user";
                  claim_value = "app-opencloud-user";
                }
                {
                  role_name = "guest";
                  claim_value = "app-opencloud-guest";
                }
              ];
            };
          };
        };

        sops.secrets."opencloud-env" = { };

        services.nginx.appendHttpConfig = ''
          map $request_uri $limit_image_req {
            default "";
            "~*\.(jpg|jpeg|png|gif|heic|webp|bmp|tiff)(\?|$)" $binary_remote_addr;
          }
          limit_req_zone $limit_image_req zone=opencloud_images:10m rate=30r/s;
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
            limit_req zone=opencloud_images burst=500;
          '';
        };

        services.restic.backups.system.paths = [ "/var/lib/opencloud" ];
      };
  };
}
