{...}: {
  flake.modules.nixos.cloudflared = {config, ...}: let
    cfg = config.features.server;
  in {
    services.cloudflared = {
      enable = true;
      tunnels."athena" = {
        credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
        default = "http_status:404";
        ingress = {
          "forgejo.${cfg.domain}" = "http://127.0.0.1:80";
          "jellyfin.${cfg.domain}" = "http://127.0.0.1:80";
        };
      };
    };

    sops.secrets."cloudflare-tunnel" = {};
  };
}
