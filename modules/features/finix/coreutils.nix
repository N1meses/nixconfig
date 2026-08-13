_: {
  aspects.finix.coreutilsGnu = {
    description = "Selects GNU coreutils as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.coreutils; };
  };
  aspects.finix.coreutilsBusybox = {
    description = "Selects busybox as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.busybox; };
  };
}
