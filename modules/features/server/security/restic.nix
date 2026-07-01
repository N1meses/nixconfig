{config, ...}: {
  flake = {
    modules.nixos.restic = {
      config,
      lib,
      ...
    }: {
      sops.secrets.restic-password = {};

      services.restic.backups.system = {
        passwordFile = config.sops.secrets.restic-password.path;
        repository = lib.mkDefault "/backup/${config.networking.hostName}";
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
        };
        pruneOpts = ["--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6"];
      };
    };
    aspectInclude.restic = with config.flake.lib.aspects; [sops];
  };
}
