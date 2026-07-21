_: {
  aspects.docker.finix = { modules, ... }: {
    imports = [
      modules.docker
      modules.sysklogd
    ];
    services.sysklogd.enable = true;
    services.docker.enable = true;
    services.docker.settings.storage-driver = "zfs";
  };
}
