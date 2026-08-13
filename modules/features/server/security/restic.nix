{ config, ... }: {
  aspects.server.security.restic = {
    description = "Nightly restic backups with retention pruning.";
    includes = with config.aspectLib.names; [ core.sops ];
    nixos =
      {
        config,
        hostName,
        lib,
        ...
      }:
      {
        sops.secrets.restic-password = { };

        services.restic.backups.system = {
          passwordFile = config.sops.secrets.restic-password.path;
          repository = lib.mkDefault "/backup/${hostName}";
          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = "1h";
          };
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 6"
          ];
        };
      };
  };
}
