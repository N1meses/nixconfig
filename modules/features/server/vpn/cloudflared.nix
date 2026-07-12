{config, ...}: {
  flake = {
    modules.nixos.cloudflared = {
      config,
      pkgs,
      lib,
      ...
    }: let
      cfg = config.features.server;
    in {
      options = {
        features.server.cloudflared.publicHosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "nginx virtualHost names exposed publicly via the cloudflare tunnel on this host.";
        };

        features.server.cloudflared.tunnelId = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Cloudflare tunnel UUID (or name) this host runs.";
        };
      };

      config = {
        services.cloudflared = {
          enable = true;
          tunnels.${cfg.cloudflared.tunnelId} = {
            credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
            default = "http_status:404";
            ingress = lib.genAttrs cfg.cloudflared.publicHosts (_: "http://127.0.0.1:80");
          };
        };

        sops.secrets."cloudflare-tunnel" = {};

        environment.systemPackages = [pkgs.cloudflared];

        assertions =
          map (h: {
            assertion = config.services.nginx.virtualHosts ? ${h};
            message = "cloudflared.publicHosts: \"${h}\" is not an nginx virtualHost on ${config.networking.hostName} (typo? service not enabled?)";
          })
          cfg.cloudflared.publicHosts;
      };
    };

    aspectInclude.cloudflared = with config.flake.lib.aspects; [nginx sops];
  };
}
