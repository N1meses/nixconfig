{ inputs, config, ... }: {
  aspects.server.share.tangled = {
    description = "Tangled knot (atproto git hosting).";
    includes = with config.aspectLib.aspectNames; [
      server.nginx
      server.security.restic
      core.sops
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
      in
      {
        imports = [ inputs.tangled.nixosModules.knot-rs ];

        services.tangled.knot-rs = {
          enable = true;
          openFirewall = false;
          environmentFile = config.sops.secrets."knot-env".path;
          settings = {
            server = {
              hostname = "knot.${cfg.domain}";
              # TODO: your DID from the PDS account; first entry is the advertised owner
              admins = [ "did:plc:REPLACE_ME" ];
              ssh_listen_addr = "[::]:2223";
            };
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

        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2223 ];

        services.restic.backups.system.paths = [ "/var/lib/knot" ];

        sops.secrets."knot-env" = { };

        services.nginx.virtualHosts."knot.${cfg.domain}" = {
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
