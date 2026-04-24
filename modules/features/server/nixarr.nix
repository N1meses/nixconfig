{inputs, ...}: {
  flake.modules.nixos.nixarr = {...}: {
    imports = [
      inputs.nixarr.nixosModules.default
    ];
    nixarr = {
      enable = true;
      mediaDir = "/media";
      stateDir = "/var/lib/nixarr";

      transmission = {
        enable = true;
        openFirewall = false;
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
    };

    users.users.sonarr.extraGroups = ["media"];
    users.users.radarr.extraGroups = ["media"];
    users.users.transmission.extraGroups = ["media"];
  };
}
