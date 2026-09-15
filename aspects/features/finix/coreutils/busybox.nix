_: {
  aspects.finix.coreutils.busybox = {
    description = "Test Matrix: Selects busybox as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.busybox; };
  };
}
