_: {
  aspects.luks.finix =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      boot.initrd.supportedFilesystems.luks.enable = true;
      boot.supportedFilesystems.luks.enable = true;

      boot.initrd.finit.tasks.luks.script = lib.mkBefore ''
        ${pkgs.busybox}/bin/loadkmap < ${config.hardware.console.binaryKeyMap} || true
      '';
    };
}
