{ inputs, config, ... }: {
  aspects.server.share.tangled = {
    description = "Tangled knot (atproto git hosting).";
    includes = with config.aspectLib.aspectNames; [
      server.nginx
      server.security.restic
      core.sops
    ];
    nixos =
      { config, lib, ... }:
      let
        cfg = config.features.server;
      in
      {
        imports = [ inputs.tangled.nixosModules.knot-rs ];

        options.features.server.knot.admins = lib.mkOption {
          type = lib.types.nonEmptyListOf lib.types.str;
          description = "DIDs with knot-admin authority; the first entry is the advertised owner.";
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
