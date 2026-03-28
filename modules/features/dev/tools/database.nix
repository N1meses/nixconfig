{...}: {
  flake.modules.homeManager.database = {pkgs, config, lib, ...}: {
    options.features.dev.tools.database.enable = lib.mkEnableOption "database tools";

    config = lib.mkIf config.features.dev.tools.database.enable {
      home.packages = with pkgs; [
        sqlite
        postgresql
      ];
    };
  };
}
