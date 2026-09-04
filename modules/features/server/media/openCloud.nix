{ config, ... }: {
  aspects.server.media.openCloud = {
    description = "openCloud aspect with collabora integration";
    includes = with config.aspectLib.names; [
      server.nginx
      server.security.restic
      core.sops
    ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.features.server;
        url = "https://cloud.${cfg.domain}";
        issuer = "https://auth.${cfg.domain}/application/o/opencloud/";

        webApps = [
          {
            name = "json-viewer";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/json-viewer-v2.1.0/json-viewer-2.1.0.zip";
              hash = "sha256-hLeyNYbcrv6mgmuupK3xCf606eEkUeOPeCa0fhL7lzo=";
            };
          }
          {
            name = "draw-io";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/draw-io-v2.2.0/draw-io-2.2.0.zip";
              hash = "sha256-CihgkGTN3DNgWfFZOQ/2Qah+4/CgjwTnw03gyxL2K4c=";
            };
          }
          {
            name = "importer";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/importer-v2.0.0/importer-2.0.0.zip";
              hash = "sha256-lT0rYs+qmWTWDXDuQMP8OZ0D6uSnmm58c3L9aypP9nQ=";
            };
          }
          {
            name = "bpmn";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/bpmn-v1.1.0/bpmn-1.1.0.zip";
              hash = "sha256-dPRuqh84p6/So00SQ2zfOY7Hn5JsAxWHHBeeyE45hKA=";
            };
          }
          {
            name = "unzip";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/unzip-v2.1.0/unzip-2.1.0.zip";
              hash = "sha256-9QlyazjiLv1kJIQFTS9zNDxI0wvS70wAlnH+zhy3dIE=";
            };
          }
          {
            name = "external-sites";
            path = pkgs.fetchzip {
              url = "https://github.com/opencloud-eu/web-extensions/releases/download/external-sites-v2.1.0/external-sites-2.1.0.zip";
              hash = "sha256-dG8/0HKG/KUzSg1oQgtBel8XEt5RI4eTdYz5cthXG0k=";
            };
          }
          {
            name = "presentation-viewer";
            path = pkgs.fetchzip {
              url = "https://github.com/JankariTech/web-app-presentation-viewer/releases/download/3.0.0/mdpresentation-viewer-Opencloud-3.0.0.zip";
              hash = "sha256-Nw9NWp3ks2yFxZCiTU+TJj3dt1T1Lg9b8+MN7JfmWRk=";
            };
          }
          {
            name = "epub";
            path = pkgs.fetchzip {
              url = "https://github.com/TubalQ/web-app-epub/releases/download/v1.0.0/epub-1.0.0.zip";
              hash = "sha256-zXCIghUUMOsQxh37KcwSRfUm9lBrsWRllLXEivpgNZ4=";
            };
          }
        ];

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
            PROXY_USER_CS3_CLAIM = "username";
            PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
            PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "opencloud-roles";
            PROXY_AUTOPROVISION_ACCOUNTS = "true";
            PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "preferred_username";
            PROXY_USER_OIDC_CLAIM = "preferred_username";

            OC_ADD_RUN_SERVICES = "collaboration";

            COLLABORATION_APP_NAME = "CollaboraOnline";
            COLLABORATION_APP_PRODUCT = "Collabora";

            COLLABORATION_APP_ADDR = "http://127.0.0.1:9980";
            COLLABORATION_APP_INSECURE = "false";

            COLLABORATION_APP_PROOF_DISABLE = "true";

            COLLABORATION_WOPI_SRC = "http://127.0.0.1:9300";
          }
          // lib.optionalAttrs (webApps != [ ]) {
            WEB_ASSET_APPS_PATH = "${pkgs.linkFarm "opencloud-web-apps" webApps}";
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
