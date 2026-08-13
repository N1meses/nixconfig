{ config, ... }: {
  aspects.navidrome.description = "Navidrome music streaming server.";
  aspects.navidrome.nixos =
    { config, ... }:
    let
      cfg = config.features.server;
    in
    {
      services.navidrome = {
        enable = true;
        settings = {
          MusicFolder = "/media/music";
          Address = "127.0.0.1";
          Port = 4533;
        };
      };

      services.restic.backups.system.paths = [ "/var/lib/navidrome" ];

      services.nginx.virtualHosts."navidrome.${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:4533";
          proxyWebsockets = true;
        };
      };

      users.users.navidrome.extraGroups = [ "media" ];
    };
  aspects.navidrome.includes = with config.aspectLib.names; [
    nginx
    restic
  ];
}
