{ config, ... }: {
  aspects.server.mail.relay = {
    description = "Send-only postfix on loopback, relaying to an authenticated smarthost.";
    includes = with config.aspectLib.aspectNames; [
      core.sops
    ];
    nixos =
      {
        config,
        lib,
        ...
      }:
      let
        cfg = config.features.server;
        mail = cfg.mail;
        relayhost = "[${mail.relay.host}]:${toString mail.relay.port}";
      in
      {
        options.features.server.mail = {
          from = lib.mkOption {
            type = lib.types.str;
            default = "noreply@notify.${cfg.domain}";
            description = "Envelope and header sender every relayed message is rewritten to.";
          };

          relay = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "smtp.tem.scaleway.com";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 465;
              description = "Implicit TLS port; there is no STARTTLS step to strip.";
            };

            username = lib.mkOption {
              type = lib.types.str;
              description = "SMTP username; for scaleway TEM the project ID (the IAM secret key is the password).";
            };
          };
        };

        config = {
          services.postfix = {
            enable = true;
            settings.main = {
              myhostname = "${config.networking.hostName}.${cfg.domain}";
              myorigin = lib.last (lib.splitString "@" mail.from);

              # null client: no local delivery, only loopback may submit
              inet_interfaces = "loopback-only";
              mynetworks = [
                "127.0.0.0/8"
                "[::1]/128"
              ];
              mydestination = "";
              local_transport = "error:local delivery is disabled";
              smtpd_relay_restrictions = "permit_mynetworks, reject";
              authorized_submit_users = "root";

              # a compromised service can only ever send as the one allowed sender
              sender_canonical_maps = "static:${mail.from}";

              # rate limits skip $mynetworks by default; loopback is the only client here
              smtpd_client_event_limit_exceptions = "";
              anvil_rate_time_unit = "3600s";
              smtpd_client_message_rate_limit = 10;
              smtpd_client_recipient_rate_limit = 20;

              relayhost = [ relayhost ];
              smtp_tls_wrappermode = "yes";
              smtp_tls_security_level = "secure";
              smtp_sasl_auth_enable = "yes";
              smtp_sasl_password_maps = "texthash:${config.sops.templates."postfix-sasl".path}";
              smtp_sasl_security_options = "noanonymous";
              smtp_sasl_tls_security_options = "noanonymous";
            };
          };

          sops.secrets."smtp-relay-password" = { };
          sops.templates."postfix-sasl" = {
            owner = config.services.postfix.user;
            content = "${relayhost} ${mail.relay.username}:${config.sops.placeholder."smtp-relay-password"}\n";
            restartUnits = [ "postfix.service" ];
          };
        };
      };
  };
}
