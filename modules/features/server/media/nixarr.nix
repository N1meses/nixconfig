{inputs, ...}: {
  flake.modules.nixos.nixarr = {config, ...}: {
    imports = [
      inputs.nixarr.nixosModules.default
    ];

    sops.secrets.mullvad-wg-conf = {};

    nixarr = {
      enable = true;
      mediaDir = "/media";
      stateDir = "/var/lib/nixarr";

      vpn = {
        enable = true;
        wgConf = config.sops.secrets.mullvad-wg-conf.path;
      };

      transmission = {
        enable = true;
        vpn.enable = true;
        extraSettings = {
          "ratio-limit" = 0;
          "ratio-limit-enabled" = true;
          "speed-limit-up" = 1;
          "speed-limit-up-enabled" = true;
          "idle-seeding-limit" = 0;
          "idle-seeding-limit-enabled" = true;
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
      autobrr = {
        enable = true;
        vpn.enable = true;
      };
      jellyseerr.enable = true;
    };

    users.users.lidarr.extraGroups = ["media"];
    users.users.readarr.extraGroups = ["media"];
    users.users.sonarr.extraGroups = ["media"];
    users.users.radarr.extraGroups = ["media"];
    users.users.transmission.extraGroups = ["media"];
  };
}
