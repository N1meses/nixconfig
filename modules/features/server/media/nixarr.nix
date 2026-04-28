{inputs, ...}: {
  flake.modules.nixos.nixarr = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.nixarr.nixosModules.default
    ];

    sops.secrets.airvpn-wg-conf = {};

    systemd.services.wg = {
      after = lib.mkAfter [ "nss-lookup.target" ];
      wants = [ "nss-lookup.target" ];
    };

    nixarr = {
      enable = true;
      mediaDir = "/media";
      stateDir = "/var/lib/nixarr";

      vpn = {
        enable = true;
        wgConf = config.sops.secrets.airvpn-wg-conf.path;
        openUdpPorts = [56599];
        openTcpPorts = [56599];
      };

      transmission = {
        enable = true;
        vpn.enable = true;
        peerPort = 56599;
        extraSettings = {
          "ratio-limit" = 0;
          "ratio-limit-enabled" = true;
          "speed-limit-up" = 250;
          "speed-limit-up-enabled" = true;
          "idle-seeding-limit" = 0;
          "idle-seeding-limit-enabled" = true;
          "cache-size-mb" = 64;
          "peer-limit-global" = 3000;
          "peer-limit-per-torrent" = 100;
          "dht-enabled" = true;
          "pex-enabled" = true;
          "utp-enabled" = true;
          "port-forwarding-enabled" = false;
        };
      };

      sonarr.enable = true;
      radarr.enable = true;
      prowlarr = {
        enable = true;
        vpn.enable = true;
      };
      lidarr.enable = true;
      readarr.enable = true;
      bazarr.enable = true;
      autobrr.enable = true;
      jellyseerr.enable = true;
    };

    users.users.lidarr.extraGroups = ["media"];
    users.users.readarr.extraGroups = ["media"];
    users.users.sonarr.extraGroups = ["media"];
    users.users.radarr.extraGroups = ["media"];
    users.users.transmission.extraGroups = ["media"];
  };
}
