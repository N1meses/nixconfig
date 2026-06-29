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
      after = lib.mkAfter ["nss-lookup.target"];
      wants = ["nss-lookup.target"];
    };

    services.restic.backups.system.paths = ["/var/lib/nixarr"];

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

      qbittorrent = {
        enable = true;
        vpn.enable = true;
        peerPort = 56599;
        webuiPort = 5252;
        extraConfig = {
          BitTorrent = {
            "Session\\GlobalMaxRatio" = 0;
            "Session\\GlobalMaxRatioLimited" = true;
            "Session\\ShareLimitAction" = "Stop";
            "Session\\GlobalUploadSpeedLimit" = 102400;
            "Session\\GlobalUTPRateLimited" = true;
            "Session\\MaxConnections" = 3000;
            "Session\\MaxConnectionsPerTorrent" = 100;
          };
        };
      };

      sonarr.enable = true;
      radarr.enable = true;
      prowlarr = {
        enable = true;
        vpn.enable = true;
      };
      lidarr.enable = true;
      bazarr.enable = true;
      autobrr.enable = true;
      jellyseerr.enable = true;
    };

    networking.firewall.interfaces."wg-br".allowedTCPPorts = [8989 7878 8686 5055 6767];

    users.users.lidarr.extraGroups = ["media"];
    users.users.readarr.extraGroups = ["media"];
    users.users.sonarr.extraGroups = ["media"];
    users.users.qbittorrent.extraGroups = ["media"];
    systemd.services.qbittorrent.serviceConfig.UMask = "0002";
    users.users.readarr = {
      isSystemUser = true;
      group = "readarr";
    };
    users.groups.readarr = {};
  };
}
