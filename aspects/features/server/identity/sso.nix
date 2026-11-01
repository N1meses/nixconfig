{
  inputs,
  config,
  ...
}:
{
  aspects.server.identity.sso = {
    description = "Authentik identity provider.";
    includes = with config.aspectLib.aspectNames; [
      server.base.nginx
      server.backup.restic
      server.mail.relay
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
            listen.metrics = [ "[::1]:9300" ];
            # loopback relay, no auth; an AUTHENTIK_EMAIL__* in authentik-env would override this
            email = {
              host = "127.0.0.1";
              port = 25;
              from = "Authentik <${cfg.mail.from}>";
            };
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

        features.server.publicHosts = [ "auth.${cfg.domain}" ];

        services.nginx.virtualHosts."auth.${cfg.domain}".locations."/".extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
        '';

        sops.secrets."authentik-env" = { };
      };
  };

  pins.authentik-nix = {
    url = "https://github.com/nix-community/authentik-nix";
    excludeFollow = [ "nixpkgs" ];
  };
}
