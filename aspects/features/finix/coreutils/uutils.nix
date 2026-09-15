_: {
  aspects.finix.coreutils.uutils = {
    description = "Test Matrix: Selects Rust uutils as the system coreutils provider.";
    finix = { pkgs, ... }: { programs.coreutils.package = pkgs.uutils-coreutils-noprefix; };
  };
}
