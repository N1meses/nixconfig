_: {
  flake.modules.nixos.nextcloud = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.features.server;
  in {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud33;
      hostName = "nextcloud.${cfg.domain}";
      maxUploadSize = "16G";
      database.createLocally = true;

      secretFile = config.sops.secrets."nextcloud-secret".path;

      config = {
        adminpassFile = config.sops.secrets."nextcloud-adminpass".path;
        dbtype = "pgsql";
      };

      settings = {
        trusted_proxies = ["127.0.0.1"];
        overwriteprotocol = "https";
        "overwrite.cli.url" = "https://nextcloud.${cfg.domain}";
      };

      phpOptions."opcache.interned_strings_buffer" = "16";
    };

    sops.secrets = {
      "nextcloud-adminpass" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
      "nextcloud-secret" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
    };

    services.postgresqlBackup = {
      enable = true;
      databases = ["nextcloud" "authentik"];
      location = "/var/backup/postgresql";
      compression = "zstd";
      startAt = "*-*-* 02:00:00";
    };

    services.restic.backups.system.paths = [
      "/var/lib/private/nextcloud"
      "var/backup/postgresql"
    ];

    users.users.nextcloud.extraGroups = ["media"];
  };
}
