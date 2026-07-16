{config, ...}: let
  flakeConfig = config;
in {
  aspects.nh.nixos = {config, ...}: let
    host = flakeConfig.registry.hosts.${config.networking.hostName} or null;
  in {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "all --keep-since 7d --keep 5";
      };
      flake = "${host.homeDirectory}/nixconfig";
    };
  };
}
