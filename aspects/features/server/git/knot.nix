{ inputs, config, ... }: {
  aspects.server.git.knot = {
    description = "Tangled knot (atproto git hosting).";
    includes = with config.aspectLib.aspectNames; [
      server.base.nginx
      server.backup.restic
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
        knot = config.services.tangled.knot-rs;

        # usage: knot-member-sync <pds-url> <knot admin command...>
        memberSync = pkgs.writeShellApplication {
          name = "knot-member-sync";
          runtimeInputs = with pkgs; [
            curl
            jq
            coreutils
          ];
          text = ''
            pds=$1
            shift
            state="''${STATE_DIRECTORY:?}/managed"
            touch "$state"

            # active = not deactivated or taken down; deleted accounts drop out of the list
            active=$(mktemp)
            next=$(mktemp)
            trap 'rm -f "$active" "$next"' EXIT
            repos=0
            cursor=""
            while :; do
              page=$(curl -fsS --get "$pds/xrpc/com.atproto.sync.listRepos" \
                --data-urlencode limit=1000 ''${cursor:+--data-urlencode "cursor=$cursor"})
              repos=$((repos + $(jq '.repos | length' <<<"$page")))
              jq -r '.repos[] | select(.active) | .did' <<<"$page" >>"$active"
              cursor=$(jq -r '.cursor // empty' <<<"$page")
              [ -n "$cursor" ] || break
            done
            # an empty PDS is a broken answer, not a reason to remove everyone
            if [ "$repos" -eq 0 ]; then
              echo "knot-member-sync: $pds listed no repos, leaving members as they are" >&2
              exit 1
            fi
            sort -u -o "$active" "$active"

            failed=0
            # adds and removes are no-ops on the knot when nothing changes, so every
            # active account is re-added each run
            while read -r did; do
              if "$@" member add "$did" >/dev/null; then
                echo "$did" >>"$next"
              else
                echo "knot-member-sync: adding $did failed" >&2
                failed=1
                if grep -qxF "$did" "$state"; then echo "$did" >>"$next"; fi
              fi
            done <"$active"

            # only members this sync added are ever removed
            while read -r did; do
              if "$@" member remove "$did" >/dev/null; then
                echo "knot-member-sync: removed $did"
              else
                echo "knot-member-sync: removing $did failed" >&2
                failed=1
                echo "$did" >>"$next"
              fi
            done < <(comm -23 <(sort -u "$state") "$active")

            sort -u "$next" >"$state.tmp"
            mv "$state.tmp" "$state"
            exit "$failed"
          '';
        };
      in
      {
        imports = [ inputs.tangled.nixosModules.knot-rs ];

        options.features.server.knot = {
          admins = lib.mkOption {
            type = lib.types.nonEmptyListOf lib.types.str;
            description = "DIDs with knot-admin authority; the first entry is the advertised owner.";
          };

          memberPds = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "http://127.0.0.1:3010";
            description = ''
              PDS whose active accounts are kept as knot members. Accounts that are deactivated,
              taken down or deleted there lose membership; members added by hand stay untouched.
            '';
          };
        };

        config.services.tangled.knot-rs = {
          enable = true;
          openFirewall = false;
          environmentFile = config.sops.secrets."knot-env".path;
          settings = {
            server = {
              hostname = "knot.${cfg.domain}";
              inherit (cfg.knot) admins;
              ssh_listen_addr = "[::]:2223";
            };
            # enables `knot-server admin` (members, invites); the value lives in knot-env
            acl.legacy_admin_secret_env = "KNOT_ADMIN_SECRET";
            git.object_format = "sha1";
            lfs.store_path = "/var/lib/knot/lfs";
            contact.email = "postmaster@${cfg.domain}";
            atproto.plc_directory = "https://plc.directory";
            xrpc = {
              trusted_proxy_header = "x-forwarded-for";
              trusted_proxies = [
                "127.0.0.1/32"
                "::1/128"
              ];
            };
          };
        };

        config.networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2223 ];

        config.services.restic.backups.system.paths = [ "/var/lib/knot" ];

        config.sops.secrets."knot-env" = { };

        config.systemd.services.knot-member-sync = lib.mkIf (cfg.knot.memberPds != null) {
          description = "Sync PDS accounts into knot members";
          after = [
            "network-online.target"
            "knot-rs.service"
          ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = knot.user;
            Group = knot.group;
            # the admin CLI needs KNOT_ADMIN_SECRET
            EnvironmentFile = knot.environmentFile;
            StateDirectory = "knot-member-sync";
            ExecStart = "${lib.getExe memberSync} ${cfg.knot.memberPds} ${lib.getExe knot.package} --config /etc/knot/config.toml admin";
          };
        };

        config.systemd.timers.knot-member-sync = lib.mkIf (cfg.knot.memberPds != null) {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "5min";
          };
        };

        config.features.server.publicHosts = [ "knot.${cfg.domain}" ];


        config.services.nginx.virtualHosts."knot.${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:5555";
            proxyWebsockets = true;
            extraConfig = "client_max_body_size 512M;";
          };
        };
      };
  };

  pins.tangled = {
    type = "git";
    url = "https://tangled.org/tangled.org/core";
    release = "*";
    excludeFollow = [ "nixpkgs" ];
  };
}
