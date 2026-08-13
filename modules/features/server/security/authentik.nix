{
  inputs,
  config,
  ...
}:
{
  aspects.server.security.authentik = {
    description = "Authentik identity provider.";
    includes = with config.aspectLib.names; [
      server.nginx
      server.security.restic
      core.sops
    ];
    nixos =
      { config, ... }:
      let
        cfg = config.features.server;
      in
      {
        imports = [ inputs.authentik-nix.nixosModules.default ];

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

        services.postgresqlBackup = {
          enable = true;
          databases = [ "authentik" ];
          location = "/var/backup/postgresql";
        };

        services.restic.backups.system.paths = [
          "/var/lib/authentik"
          "/var/backup/postgresql"
        ];

        services.nginx.virtualHosts."auth.${cfg.domain}".locations."/".extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
        '';

        sops.secrets."authentik-env" = { };
      };
  };
}
