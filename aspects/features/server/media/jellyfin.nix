{ config, ... }: {
  aspects.server.media.jellyfin = {
    description = "Jellyfin media server, proxied and backed up.";
    includes = with config.aspectLib.aspectNames; [
      server.base.nginx
      server.backup.restic
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
      in
      {
        services.jellyfin.enable = true;

        features.server.publicHosts = [ "jellyfin.${cfg.domain}" ];


        services.nginx.virtualHosts."jellyfin.${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
            extraConfig = "proxy_buffering off;";
          };
        };

        services.restic.backups.system.paths = [ "/var/lib/jellyfin" ];

        users.users.jellyfin.extraGroups = [
          "media"
          "render"
          "video"
        ];
      };
  };
}
