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
      { config, ... }:
      let
        cfg = config.features.server;
      in
      {
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
              # handles are <name>.<domain>, resolved via the wildcard vhost below
              user_handle_domains = [ cfg.domain ];
              # authentik is the gate: sso sign-up has no invite exemption upstream, so invites
              # are off and the non-sso sign-up routes are refused in nginx below
              invite_code_required = false;
            };
            email = {
              from_address = config.features.server.mail.from;
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

        services.nginx.virtualHosts."pds.${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:3010";
            proxyWebsockets = true;
            extraConfig = "client_max_body_size 100M;";
          };
          # password/passkey sign-up and migrations; only /oauth/sso/complete-registration creates accounts
          locations."^~ /xrpc/com.atproto.server.createAccount".return = "403";
          locations."^~ /xrpc/_account.createPasskeyAccount".return = "403";
        };

        # explicit service vhosts win over the wildcard; it only answers handle lookups
        services.nginx.virtualHosts."*.${cfg.domain}" = {
          locations."= /.well-known/atproto-did".proxyPass = "http://127.0.0.1:3010";
          locations."/".return = "404";
        };
      };
  };
}
