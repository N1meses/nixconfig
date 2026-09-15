_: {
  aspects.finix.docker = {
    description = "Docker daemon with syslog wiring.";
    finix = { modules, ... }: {
      imports = [
        modules.docker
        modules.sysklogd
      ];
      services.sysklogd.enable = true;
      services.docker.enable = true;
      services.docker.settings.storage-driver = "zfs";
    };
  };
}
