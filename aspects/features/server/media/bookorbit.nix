{ config, ... }:
{
  aspects.server.media.bookorbit = {
    description = "BookOrbit library and reader (ebooks, comics, audiobooks) with Kobo/KOReader sync.";
    includes = with config.aspectLib.aspectNames; [
      server.base.nginx
      server.backup.restic
      core.sops
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
        port = 5002;
        host = "books.${cfg.domain}";
      in
      {
        # nixpkgs module: service, migration oneshot, and the bookorbit db + extensions on the
        # host's existing postgresql (createDatabaseLocally defaults to true)
        services.bookorbit = {
          enable = true;
          environment = {
            PORT = port;
            HOST = "127.0.0.1";
            APP_URL = "https://${host}";
            # folder picker in "create library" starts here instead of /
            LIBRARY_BROWSE_ROOT = "/media/books";
          };
          environmentFile = config.sops.templates."bookorbit.env".path;
        };

        sops.secrets."bookorbit-jwt-secret" = { };
        sops.secrets."bookorbit-setup-token" = { };
        sops.templates."bookorbit.env" = {
          content = ''
            JWT_SECRET=${config.sops.placeholder."bookorbit-jwt-secret"}
            SETUP_BOOTSTRAP_TOKEN=${config.sops.placeholder."bookorbit-setup-token"}
          '';
          restartUnits = [ "bookorbit.service" ];
        };

        # read access works without this (library files are world-readable);
        # needed for uploads, Book Dock and metadata write-back into /media/books
        users.users.bookorbit.extraGroups = [ "media" ];

        systemd.tmpfiles.rules = [
          "d '/media/books'        0775 root media - -"
          "d '/media/books/books'  0775 root media - -"
          "d '/media/books/novels' 0775 root media - -"
          "d '/media/books/comics' 0775 root media - -"
        ];

        features.server.publicHosts = [ host ];

        services.nginx.virtualHosts.${host} = {
          # Kobo sync sends large headers; uploads go through the web UI
          extraConfig = ''
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            large_client_header_buffers 8 32k;
            client_max_body_size 0;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString port}";
            proxyWebsockets = true;
            # Kobo builds cover/download URLs from the forwarded port; public access is always 443
            extraConfig = ''
              proxy_set_header X-Forwarded-Port 443;
            '';
          };
        };

        services.postgresqlBackup = {
          enable = true;
          databases = [ "bookorbit" ];
          location = "/var/backup/postgresql";
        };

        services.restic.backups.system.paths = [
          "/var/lib/bookorbit"
          "/var/backup/postgresql"
        ];
      };
  };
}
