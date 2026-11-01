{ config, ... }: {
  aspects.server.network.cloudflared = {
    description = "Cloudflare tunnel exposing declared nginx vhosts publicly.";
    includes = with config.aspectLib.aspectNames; [
      server.base.nginx
      core.sops
    ];
    nixos =
      {
        config,
        hostName,
        pkgs,
        lib,
        ...
      }:
      let
        cfg = config.features.server;
      in
      {
        options = {
          features.server.cloudflared.tunnelId = lib.mkOption {
            type = lib.types.str;
            default = hostName;
            description = "Cloudflare tunnel UUID (or name) this host runs.";
          };
        };

        config = {
          services.cloudflared = {
            enable = true;
            tunnels.${cfg.cloudflared.tunnelId} = {
              credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
              default = "http_status:404";
              ingress = lib.genAttrs cfg.publicHosts (_: "http://127.0.0.1:80");
            };
          };

          sops.secrets."cloudflare-tunnel" = { };

          environment.systemPackages = [ pkgs.cloudflared ];

          assertions = map (h: {
            assertion = config.services.nginx.virtualHosts ? ${h};
            message = "publicHosts: \"${h}\" is not an nginx virtualHost on ${hostName} (typo? service not enabled?)";
          }) cfg.publicHosts;
        };
      };
  };

}
