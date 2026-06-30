{config, ...}: {
  flake = {
    modules.nixos.ocis = {config, ...}: let
      cfg = config.features.server;
      ocisUrl = "https://cloud.${cfg.domain}";
      issuer = "https://auth.${cfg.domain}/application/o/ocis/";
    in {
      services.ocis = {
        enable = true;
        address = "127.0.0.1";
        port = 9200;
        url = ocisUrl;

        environmentFile = config.sops.secrets.ocis-env.path;

        environment = {
          OCIS_URL = ocisUrl;
          OCIS_LOG_LEVEL = "error";
          OCIS_INSECURE = "false";
          PROXY_TLS = "false";

          OCIS_OIDC_ISSUER = issuer;
          OCIS_EXCLUDE_RUN_SERVICES = "idp";
          WEB_OIDC_CLIENT_ID = "ocis";
          WEB_OIDC_SCOPE = "openid profile email";
          PROXY_OIDC_REWRITE_WELLKNOWN = "true";
          PROXY_AUTOPROVISION_ACCOUNTS = "true";
          PROXY_USER_OIDC_CLAIM = "preferred_username";
          PROXY_USER_CS3_CLAIM = "username";
          PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
          # PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "roles";
        };
      };

      services.nginx.virtualHosts."cloud.${cfg.domain}".locations."/" = {
        proxyPass = "http://127.0.0.1:9200";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 0;
          proxy_request_buffering off;
          proxy_read_timeout 3600s;
        '';
      };

      services.restic.backups.system.paths = ["/var/lib/ocis"];
      sops.secrets.ocis-env = {
        sopsFile = ../../../../secrets/athena.yaml;
      };
    };
    aspectInclude.ocis = with config.flake.lib.aspects; [nginx restic];
  };
}
