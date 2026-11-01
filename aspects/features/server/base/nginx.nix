_: {
  aspects.server.base.nginx = {
    description = "nginx reverse proxy with ACME-backed TLS.";
    nixos =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      let
        cfg = config.features.server;
        ingress = cfg.nginx.ingress;
      in
      {
        # every proxied location gets this one header set instead of the recommended include,
        # vhosts from other modules included
        options.services.nginx.virtualHosts = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.locations = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule (
                    { config, ... }:
                    {
                      # a module that sets recommendedProxySettings itself keeps the stock include
                      config = lib.mkMerge [
                        (lib.mkIf (config.proxyPass != null) { recommendedProxySettings = lib.mkDefault false; })
                        (lib.mkIf (config.proxyPass != null && !config.recommendedProxySettings) {
                          extraConfig = lib.mkBefore ''
                            proxy_set_header Host $host;
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $remote_addr;
                            proxy_set_header X-Forwarded-Proto $forwarded_proto;
                            proxy_set_header X-Forwarded-Host $host;
                            proxy_set_header X-Forwarded-Server $hostname;
                          '';
                        })
                      ];
                    }
                  )
                );
              };
            }
          );
        };

        options.features.server.nginx.ingress = {
          proxies = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Socket addresses of a front proxy nginx trusts for the client address.";
          };

          clientHeader = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "CF-Connecting-IP";
            description = "Header the front proxy puts the client address in.";
          };

          https = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "The front proxy terminated TLS, so its plain-HTTP requests are forwarded as https.";
          };
        };

        options.features.server = {
          domain = lib.mkOption {
            type = lib.types.str;
            default = "";
          };

          tls = lib.mkEnableOption "Tailscale HTTPS for nginx";

          publicHosts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "nginx virtualHost names meant to be reachable from outside; service aspects add their own, the host's ingress (cloudflared) exposes them.";
          };
        };

        config = {
          services.nginx = {
            enable = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = lib.mkIf cfg.tls true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            # $realip_remote_addr is the socket peer, so only the front proxy itself can claim https
            commonHttpConfig = ''
              ${lib.concatMapStrings (p: "set_real_ip_from ${p};\n") ingress.proxies}
              ${lib.optionalString (ingress.clientHeader != null) "real_ip_header ${ingress.clientHeader};"}
              map $realip_remote_addr $forwarded_proto {
                default $scheme;
                ${lib.optionalString ingress.https (lib.concatMapStrings (p: "${p} https;\n") ingress.proxies)}
              }
            '';
          };

          networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
            80
          ]
          ++ lib.optionals cfg.tls [ 443 ];

          systemd.services.tailscale-cert-copy = lib.mkIf cfg.tls {
            description = "Fetch Tailscale TLS cert for nginx";
            after = [
              "tailscaled.service"
              "network-online.target"
              "sys-subsystem-net-devices-tailscale0.device"
            ];
            wants = [ "network-online.target" ];
            wantedBy = [ "nginx.service" ];
            before = [ "nginx.service" ];
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
  };
}
