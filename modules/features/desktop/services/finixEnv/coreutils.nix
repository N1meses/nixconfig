_: {
  aspects.coreutilsGnu.description = "Selects GNU coreutils as the system coreutils provider.";
  aspects.coreutilsGnu.finix = { pkgs, ... }: { programs.coreutils.package = pkgs.coreutils; };
  aspects.coreutilsBusybox.description = "Selects busybox as the system coreutils provider.";
  aspects.coreutilsBusybox.finix = { pkgs, ... }: { programs.coreutils.package = pkgs.busybox; };
}
