{ inputs, config, ... }: {
  aspects.server.share.spindle = {
    description = "Tangled spindle (CI runner, microVM engine).";
    includes = with config.aspectLib.aspectNames; [
      server.nginx
      server.security.restic
      server.share.tangled
      core.sops
    ];
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.features.server;
      in
      {
        imports = [ inputs.tangled.nixosModules.spindle ];

        options.features.server.spindle.allowList = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "DIDs besides the owner that may run CI; entries are only ever added, never removed.";
        };

        # the module also turns on docker for the nixery engine
        config.services.tangled.spindle = {
          enable = true;
          server = {
            hostname = "spindle.${cfg.domain}";
            owner = lib.head cfg.knot.admins;
            listenAddr = "127.0.0.1:6555";
            corsOrigins = [ "https://tangled.org" ];
          };
          keyPath = config.sops.secrets."spindle-key".path;
          contact.email = "postmaster@${cfg.domain}";
          inherit (cfg.spindle) allowList;
          # enforce per-workflow memory/pids limits instead of only accounting for them
          pipelines.microvm.cgroup.enable = true;
          # logs stay on disk under /var/log/spindle
          artifactStores.s3.bucket = "";
        };

        config.systemd.tmpfiles.rules = [
          "L+ /var/lib/spindle/images/nixos - - - - ${
            inputs.tangled.packages.${pkgs.stdenv.hostPlatform.system}.spindle-nixos-image
          }"
        ];

        # holds spindle.db with the repo secrets
        config.services.restic.backups.system.paths = [ "/var/lib/spindle" ];

        config.sops.secrets."spindle-key" = { };

        config.services.nginx.virtualHosts."spindle.${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:6555";
            proxyWebsockets = true;
          };
        };
      };
  };
}
