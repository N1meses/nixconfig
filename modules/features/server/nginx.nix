{...}: {
  flake.modules.nixos.nginx = {
    lib,
    pkgs,
    config,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      tls = lib.mkEnableOption "Tailscale HTTPS for nginx";
    };

    config = {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = lib.mkIf cfg.tls true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts =
        [80] ++ lib.optionals cfg.tls [443];

      systemd.services.tailscale-cert-copy = lib.mkIf cfg.tls {
        description = "Fetch Tailscale TLS cert for nginx";
        after = ["tailscaled.service" "network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["nginx.service"];
        before = ["nginx.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.coreutils}/bin/mkdir -p /var/lib/tailscale/certs /var/lib/nginx/certs
          ${pkgs.tailscale}/bin/tailscale cert \
            --cert-file /var/lib/tailscale/certs/${cfg.domain}.crt \
            --key-file /var/lib/tailscale/certs/${cfg.domain}.key \
            ${cfg.domain}
          ${pkgs.coreutils}/bin/install -m 644 -o nginx -g nginx \
            /var/lib/tailscale/certs/${cfg.domain}.crt /var/lib/nginx/certs/${cfg.domain}.crt
          ${pkgs.coreutils}/bin/install -m 640 -o nginx -g nginx \
            /var/lib/tailscale/certs/${cfg.domain}.key /var/lib/nginx/certs/${cfg.domain}.key
        '';
      };

      services.fail2ban.jails = {
        nginx-http-auth.settings = {
          enabled = true;
          port = "http,https";
          filter = "nginx-http-auth";
          maxretry = 5;
        };
        nginx-botsearch.settings = {
          enabled = true;
          port = "http,https";
          filter = "nginx-botsearch";
          maxretry = 2;
        };
      };
    };
  };
}
