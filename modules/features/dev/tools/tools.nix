{ config, ... }: let
  flakeConfig = config;
in {
  flake.modules.homeManager.tools = {pkgs, ...}: {
    imports = with flakeConfig.flake.modules.homeManager; [
      git
      direnv
      database
      opencode
      security
    ];

    home.packages = with pkgs; [
      jq
      just
      hyperfine
      gh
      tokei
      watchexec
      sd
      bandwhich
      gnumake
      cmake
      pkg-config
      httpie
      yq
      btop
    ];
  };
}
