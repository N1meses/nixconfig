{
  inputs,
  config,
  ...
}: {
  flake = {
    modules.nixos.authentik = {config, ...}: let
      cfg = config.features.server;
    in {
      imports = [inputs.authentik-nix.nixosModules.default];

      services.authentik = {
        enable = true;
        environmentFile = config.sops.secrets."authentik-env".path;
        settings = {
          disable_startup_analytics = true;
          avatars = "initials";
        };
        nginx = {
          enable = true;
          host = "auth.${cfg.domain}";
        };
      };

      services.restic.backups.system.paths = ["/var/lib/authentik"];

      services.nginx.virtualHosts."auth.${cfg.domain}".locations."/".extraConfig = ''
        proxy_set_header X-Forwarded-Proto https;
      '';

      sops.secrets."authentik-env" = {};
    };
    aspectInclude.authentik = with config.flake.lib.aspects; [nginx restic];
  };
}
