{ config, ... }: {
  aspects.server.mail.alerts = {
    description = "Mail alerts through the relay: ZFS events, SMART failures and failed units.";
    includes = with config.aspectLib.aspectNames; [ server.mail.relay ];
    nixos =
      { config, lib, ... }:
      let
        cfg = config.features.server;
        alerts = cfg.mail.alerts;
        sendmail = "${config.security.wrapperDir}/${config.services.mail.sendmailSetuidWrapper.program}";
      in
      {
        options.features.server.mail.alerts = {
          to = lib.mkOption {
            type = lib.types.str;
            default = "postmaster@${cfg.domain}";
            description = "Recipient of every alert; the relay only sends, so this has to be a real mailbox.";
          };

          units = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "restic-backups-system" ];
            description = "systemd services that mail their status and recent log when they fail.";
          };
        };

        config = {
          # the defaults mail root, which has no mailbox behind a send-only relay
          services.zfs.zed.settings = {
            ZED_EMAIL_ADDR = [ alerts.to ];
            ZED_NOTIFY_INTERVAL_SECS = 3600;
          };

          services.smartd = {
            enable = true;
            notifications.mail = {
              recipient = alerts.to;
              sender = cfg.mail.from;
            };
          };

          # a marker per failing unit: the first failure mails, a unit that keeps failing
          # (knot-member-sync runs every 5 min) reminds once a day, the next success mails once.
          # test with: systemctl start alert-failure@test.service
          systemd.services = {
            "alert-failure@" = {
              description = "Mail the status of failed unit %i";
              scriptArgs = "%i";
              script = ''
                unit=$1
                marker=$STATE_DIRECTORY/$unit
                if [ -e "$marker" ] && [ $(($(date +%s) - $(stat -c %Y "$marker"))) -lt 86400 ]; then
                  exit 0
                fi
                touch "$marker"
                {
                  echo "To: ${alerts.to}"
                  echo "Subject: [${config.networking.hostName}] $unit failed"
                  echo
                  echo "Further failures are mailed at most once a day until it succeeds again."
                  echo
                  systemctl status --full --no-pager --lines=0 "$unit" || true
                  echo
                  journalctl --unit "$unit" --lines 50 --no-pager --output short-iso || true
                } | ${sendmail} -i ${lib.escapeShellArg alerts.to}
              '';
              serviceConfig = {
                Type = "oneshot";
                StateDirectory = "alert-failure";
              };
            };

            "alert-recovered@" = {
              description = "Mail that unit %i succeeds again";
              scriptArgs = "%i";
              script = ''
                unit=$1
                marker=$STATE_DIRECTORY/$unit
                [ -e "$marker" ] || exit 0
                rm "$marker"
                {
                  echo "To: ${alerts.to}"
                  echo "Subject: [${config.networking.hostName}] $unit recovered"
                  echo
                  journalctl --unit "$unit" --lines 20 --no-pager --output short-iso || true
                } | ${sendmail} -i ${lib.escapeShellArg alerts.to}
              '';
              serviceConfig = {
                Type = "oneshot";
                StateDirectory = "alert-failure";
              };
            };
          }
          // lib.genAttrs alerts.units (_: {
            onFailure = [ "alert-failure@%n.service" ];
            onSuccess = [ "alert-recovered@%n.service" ];
          });
        };
      };
  };
}
