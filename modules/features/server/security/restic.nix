{ config, ... }: {
  aspects.restic.description = "Nightly restic backups with retention pruning.";
  aspects.restic.nixos =
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
  aspects.restic.includes = with config.aspectLib.names; [ sops ];
}
