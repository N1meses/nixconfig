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

        dictionaries = [
          pkgs.hunspellDicts.de_DE
          pkgs.hunspellDicts.en_US
          pkgs.hyphenDicts.de_DE
          pkgs.hyphenDicts.en_US
        ];

        installDictionaries = pkgs.writeShellScript "coolwsd-dictionaries" ''
          set -eu
          share=/var/lib/cool/systemplate/usr/share
          ${pkgs.coreutils}/bin/install -d "$share/hunspell" "$share/hyphen"
          for dict in ${lib.escapeShellArgs dictionaries}; do
            for kind in hunspell hyphen; do
              if [ -d "$dict/share/$kind" ]; then
                ${pkgs.coreutils}/bin/cp -Lf "$dict/share/$kind/"* "$share/$kind/"
              fi
            done
          done
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

            admin_console.enable = false;
          };
        };

        systemd.services.coolwsd-systemplate-setup.serviceConfig.ExecStartPost = [
          "${installDictionaries}"
        ];

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
