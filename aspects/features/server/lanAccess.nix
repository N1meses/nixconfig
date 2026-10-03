{ config, ... }: {
  aspects.server.lanAccess = {
    description = "Direct LAN HTTPS to nginx vhosts via a wildcard ACME cert (DNS-01, Cloudflare); pair with split-horizon DNS.";
    includes = with config.aspectLib.aspectNames; [
      server.nginx
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
      in
      {
        options.features.server.lanAccess = {
          hosts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "nginx virtualHost names served over HTTPS on the LAN.";
          };

          interface = lib.mkOption {
            type = lib.types.str;
            description = "LAN interface 443 is opened on.";
          };
        };

        config = {
          security.acme = {
            acceptTerms = true;
            certs.${cfg.domain} = {
              domain = cfg.domain;
              extraDomainNames = [ "*.${cfg.domain}" ];
              dnsProvider = "cloudflare";
              dnsResolver = "1.1.1.1:53";
              environmentFile = config.sops.secrets."cloudflare-acme".path;
              group = config.services.nginx.group;
            };
          };

          services.nginx.virtualHosts = lib.genAttrs cfg.lanAccess.hosts (_: {
            useACMEHost = cfg.domain;
            addSSL = true;
          });
          services.nginx.recommendedTlsSettings = true;

          networking.firewall.interfaces.${cfg.lanAccess.interface}.allowedTCPPorts = [ 443 ];

          sops.secrets."cloudflare-acme" = { };

          assertions = map (h: {
            assertion = config.services.nginx.virtualHosts.${h}.locations != { };
            message = "lanAccess.hosts: \"${h}\" has no locations (typo? service not enabled?)";
          }) cfg.lanAccess.hosts;
        };
      };
  };
}
