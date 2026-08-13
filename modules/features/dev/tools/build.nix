_: {
  aspects.build.description = "Build tooling (compilers, make, and friends).";
  aspects.build.home = { pkgs, ... }: {
    packages = with pkgs; [
      gnumake
      cmake
      pkg-config
    ];
  };
}
