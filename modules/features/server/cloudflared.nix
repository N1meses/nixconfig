{config, ...}: let
  cfg = config.features.server;
in {
  flake.modules.nixos.cloudflared = {config, ...}: {
    services.cloudflared = {
      enable = true;
      tunnels."hephaistos" = {
        credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
        default = "http_status:404";
        ingress = {
          "forgejo.${cfg.domain}" = "http://127.0.0.1:3000";
          "vault.${cfg.domain}" = "http://127.0.0.1:8222";
          "media.${cfg.domain}" = "http://127.0.0.1:8096";
        };
      };
    };

    sops.secrets."cloudflare-tunnel" = {};
  };
}
