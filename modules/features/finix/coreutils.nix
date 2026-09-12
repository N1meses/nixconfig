_: {
  aspects.finix.coreutilsGnu = {
    description = "Test Matrix: Selects GNU coreutils as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.coreutils; };
  };
  aspects.finix.coreutilsBusybox = {
    description = "Test Matrix: Selects busybox as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.busybox; };
  };
  aspects.finix.coreuutils = {
    description = "Test Matrix: Selects Rust Coreutils as the system corutils";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.uutils-coreutils-noprefix; };
  };
}
