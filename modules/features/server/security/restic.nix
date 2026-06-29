_: {
  flake.modules.nixos.restic = {
    config,
    lib,
    ...
  }: {
    services.restic.backups = {
      passwordFile = config.sops.secrets.restic-password.path;
      repository = lib.mkDefault "/backup/${config.networking.hostName}";
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
      };
      pruneOpts = ["--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6"];
    };
  };
}
