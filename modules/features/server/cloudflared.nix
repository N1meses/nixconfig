{...}: {
  flake.modules.nixos.cloudflared = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server.cloudflared = {
      enable = lib.mkEnableOption "cloudflared";
    };

    config = lib.mkIf cfg.cloudflared.enable {
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
  };
}
