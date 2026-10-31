{ config, ... }: {
  aspects.server.share.tranquil = {
    description = "Tranquil atproto PDS with authentik SSO.";
    includes = with config.aspectLib.aspectNames; [
      server.nginx
      server.security.restic
      server.mail.relay
      core.sops
    ];
    nixos =
      { config, lib, ... }:
      let
        cfg = config.features.server;
        pds = cfg.pds;
        registrationDisabled = ''
          default_type application/json;
          return 403 '{"error":"RegistrationDisabled","message":"Sign-up is only available via Authentik."}';
        '';
        # explicit service vhosts win over a wildcard; it only answers handle lookups
        handleVhost = {
          locations."= /.well-known/atproto-did".proxyPass = "http://127.0.0.1:3010";
          locations."/".return = "404";
        };
      in
      {
        options.features.server.pds = {
          handleDomain = lib.mkOption {
            type = lib.types.str;
            default = cfg.domain;
            description = "Domain new handles are issued under (<name>.<handleDomain>); needs a wildcard DNS record.";
          };

          legacyHandleDomains = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Domains that still serve handle lookups for existing accounts, but issue no new handles.";
          };

          ssoOnly = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Accounts are only created via SSO: invites are off and nginx refuses the password/passkey
              sign-up routes (which also blocks migrations in). Workaround until upstream can exempt
              SSO from invites.
            '';
          };
        };

        config = {
          services.tranquil-pds = {
            enable = true;
            database.createLocally = true;
            # JWT_SECRET, DPOP_SECRET, MASTER_KEY, SSO_OIDC_ENABLED=true, SSO_OIDC_CLIENT_SECRET
            environmentFiles = [ config.sops.secrets."tranquil-env".path ];
            settings = {
              server = {
                hostname = "pds.${cfg.domain}";
                host = "127.0.0.1";
                port = 3010;
                enable_caddy_on_demand_tls = false;
                # cloudflared -> nginx -> tranquil
                trusted_proxy_count = 2;
                user_handle_domains = [ pds.handleDomain ];
                invite_code_required = !pds.ssoOnly;
              };
              email = {
                from_address = cfg.mail.from;
                # loopback postfix holds the upstream credential
                smarthost = {
                  host = "127.0.0.1";
                  port = 25;
                  tls = "none";
                };
              };
              # enabled comes from env: the build-time `validate` would otherwise demand the secret
              sso.oidc = {
                client_id = "pds";
                issuer = "https://auth.${cfg.domain}/application/o/pds/";
                display_name = "Authentik";
              };
            };
          };

          # the module renders config.toml into /etc without a restart trigger
          systemd.services.tranquil-pds.restartTriggers = [
            config.environment.etc."tranquil-pds/config.toml".source
          ];

          services.postgresqlBackup = {
            enable = true;
            databases = [ "tranquil-pds" ];
            location = "/var/backup/postgresql";
          };

          services.restic.backups.system.paths = [
            "/var/lib/tranquil-pds"
            "/var/backup/postgresql"
          ];

          sops.secrets."tranquil-env" = { };

          services.nginx.virtualHosts = {
            "pds.${cfg.domain}".locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:3010";
                proxyWebsockets = true;
                extraConfig = "client_max_body_size 100M;";
              };
            }
            // lib.optionalAttrs pds.ssoOnly {
              # json body: the frontend parses every response before checking the status
              "^~ /xrpc/com.atproto.server.createAccount".extraConfig = registrationDisabled;
              "^~ /xrpc/_account.createPasskeyAccount".extraConfig = registrationDisabled;
            };
          }
          // lib.genAttrs (map (d: "*.${d}") ([ pds.handleDomain ] ++ pds.legacyHandleDomains)) (
            _: handleVhost
          );
        };
      };
  };
}
