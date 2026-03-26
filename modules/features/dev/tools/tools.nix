{
  config,
  lib,
  ...
}: let
  cfg = config.features.dev.tools;
in {
  options.features.dev.tools = {
    database.enable = lib.mkEnableOption "Enable the database tools";
    ai.enable = lib.mkEnableOption "Enable the AI tools";
    security.enable = lib.mkEnableOption "Enable the security tools";
  };

  config = {
    flake.modules.homeManager.tools = {pkgs, ...}: {
      imports = with config.flake.modules.homeManager;
        [
          git
          direnv
        ]
        ++ lib.optional cfg.database.enable database
        ++ lib.optional cfg.ai.enable ai
        ++ lib.optional cfg.security.enable security;

      home.packages = with pkgs; [
        jq
        just
        hyperfine
        gh
        tokei
        watchexec
        sd
        bandwhich
      ];
    };
  };
}
