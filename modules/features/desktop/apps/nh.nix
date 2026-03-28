{...}: {
  flake.modules.homeManager.nh = {config, lib, ...}: {
    options.features.apps.nh.enable = lib.mkEnableOption "nix helper (nh)";

    config = lib.mkIf config.features.apps.nh.enable {
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "all --keep-since 7d --keep 5";
        };
        flake = "/home/nimeses/nixconfig";
      };
    };
  };
}
