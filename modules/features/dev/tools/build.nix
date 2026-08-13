_: {
  aspects.dev.tools.build = {
    description = "Build tooling (compilers, make, and friends).";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        gnumake
        cmake
        pkg-config
      ];
    };
  };
}
