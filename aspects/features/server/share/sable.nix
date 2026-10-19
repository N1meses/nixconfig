{ config, ... }: {
  aspects.server.share.sable = {
    description = "Sable web client.";
    includes = with config.aspectLib.aspectNames; [ server.nginx ];
    nixos =
      {
        config,
        pkgs,
        ...
      }:
      let
        cfg = config.features.server;

        version = "2.0.3";
        web = pkgs.fetchzip {
          url = "https://git.sable.moe/SableClient/sable-next/releases/download/v${version}/sable-${version}-web.tar.gz";
          hash = "sha256-az9Z+DFMSgzrgzvRkbbxNWWvgH+jZSTX1zsf2iCpYDc=";
          stripRoot = false;
        };

        conf = pkgs.writeText "sable-config.json" (
          builtins.toJSON {
            homeserverList = [ "matrix.${cfg.domain}" ];
            defaultHomeserver = 0;
            allowCustomHomeservers = false;
            hideUsernamePasswordFields = true;
            settingsDefaults.theme = "dark";
          }
        );

        root = pkgs.runCommand "sable-${version}" { } ''
          mkdir $out
          ln -s ${web}/* $out
          rm $out/config.json
          ln -s ${conf} $out/config.json
        '';
      in
      {
        services.nginx.virtualHosts."sable.${cfg.domain}" = {
          inherit root;
          locations."/".extraConfig = "try_files $uri $uri.html $uri/index.html /index.html;";
          locations."/_app/immutable/".extraConfig = ''
            add_header Cache-Control "public, max-age=31536000, immutable";
          '';
          locations."= /index.html".extraConfig = ''add_header Cache-Control "no-cache";'';
          locations."= /config.json".extraConfig = ''add_header Cache-Control "no-cache";'';
          locations."= /manifest.webmanifest".extraConfig = ''
            default_type application/manifest+json;
          '';
        };
      };
  };
}
