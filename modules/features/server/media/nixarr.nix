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
          "ratio_limit" = 0;
          "ratio_limit_enabled" = true;
          "speed_limit_up" = 1;
          "speed_limit_up_enabled" = true;
          "idle_seeding_limit" = 0;
          "idle_seeding_limit_enabled" = true;
        };
      };

      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
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
