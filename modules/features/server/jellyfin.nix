{...}: {
  flake.modules.nixos.jellyfin = {
    lib,
    config,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server = {
      jellyfin.enable = lib.mkEnableOption "jellyfin media server";
    };

    config = lib.mkIf cfg.jellyfin.enable {
      services.jellyfin.enable = true;

      services.nginx.virtualHosts."media.${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = "proxy_buffering off;";
        };
      };
    };
  };
}
