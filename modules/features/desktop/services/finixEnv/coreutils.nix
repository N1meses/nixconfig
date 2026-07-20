_: {
  aspects.coreutilsGnu.finix = { pkgs, ... }: { programs.coreutils.package = pkgs.coreutils; };
  aspects.coreutilsBusybox.finix = { pkgs, ... }: { programs.coreutils.package = pkgs.busybox; };
}
