{...}: {
  flake.modules.nixos.jellyfin = {config, ...}: let
    cfg = config.features.server;
  in {
    services.jellyfin.enable = true;

    services.nginx.virtualHosts."jellyfin.${cfg.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = "proxy_buffering off;";
      };
    };

    services.restic.backups.system.paths = [ "/var/lib/jellyfin" ];

    users.users.jellyfin.extraGroups = ["media" "render" "video"];
  };
}
