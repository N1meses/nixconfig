{ config, ... }:
{
  aspects.server.media.collabora = {
    description = "Collabora Online, the WOPI document server OpenCloud edits through.";
    includes = with config.aspectLib.names; [
      server.nginx
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

        dictionaries = pkgs.runCommand "coolwsd-dictionaries" { } ''
          mkdir -p $out
          cp -L ${pkgs.hunspellDicts.de_DE}/share/hunspell/* $out/
          cp -L ${pkgs.hunspellDicts.en_US}/share/hunspell/* $out/
          cp -L ${pkgs.hyphenDicts.de_DE}/share/hyphen/* $out/
          cp -L ${pkgs.hyphenDicts.en_US}/share/hyphen/* $out/
        '';

        reclaimStateDir = pkgs.writeShellScript "coolwsd-reclaim-statedir" ''
          set -eu
          ${pkgs.coreutils}/bin/install -d /var/lib/cool/child-roots
          ${pkgs.coreutils}/bin/chown -R cool:cool /var/lib/cool
        '';
      in
      {
        services.collabora-online = {
          enable = true;
          port = 9980;

          aliasGroups = [ { host = ''http://127\.0\.0\.1:9300''; } ];

          settings = {
            ssl.enable = false;
            ssl.termination = true;

            server_name = "office.${cfg.domain}";

            storage.wopi."@allow" = true;

            net.content_security_policy = "frame-ancestors office.${cfg.domain}:* https://cloud.${cfg.domain}";

            admin_console.enable = false;
          };
        };

        systemd.services.coolwsd.environment.DICPATH = "${dictionaries}";

        systemd.services.coolwsd-systemplate-setup = {
          path = [
            pkgs.cpio
            pkgs.glibc.bin
          ];
          serviceConfig = {
            User = lib.mkForce "root";
            ExecStartPost = [ "${reclaimStateDir}" ];
          };
        };

        services.nginx.virtualHosts."office.${cfg.domain}".locations."/" = {
          proxyPass = "http://127.0.0.1:9980";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 0;
            proxy_read_timeout 36000s;
            proxy_send_timeout 36000s;
            proxy_set_header X-Forwarded-Proto https;
          '';
        };
      };
  };
}
