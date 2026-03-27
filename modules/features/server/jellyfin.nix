{config, ...}: let
  cfg = config.features.server;
in {
  flake.modules.nixos.jellyfin = {...}: {
    services.jellyfin.enable = true;

    services.nginx.virtualHosts."media.${cfg.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = "proxy_buffering off;";
      };
    };
  };
}
