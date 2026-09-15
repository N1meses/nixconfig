_: {
  aspects.finix.coreutils.gnu = {
    description = "Test Matrix: Selects GNU coreutils as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.coreutils; };
  };
}
