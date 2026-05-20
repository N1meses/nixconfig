{...}: {
  flake.modules.nixos.matrix = {config, ...}: let
    cfg = config.features.server;
  in {
    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        server_name = "matrix.${cfg.domain}";
        port = [6167];
        allow_registration = true;
        allow_federation = true;
        registration_token_file = config.sops.secrets."matrix-registration-token".path;
        new_user_displayname_suffix = "";
        require_auth_for_profile_requests = true;
        encryption_enabled_by_default_for_room_type = "private_chat";
        allow_public_room_directory_over_federation = false;
        forget_forced_upon_leave = true;
      };
    };

    sops.secrets."matrix-registration-token" = {};

    services.nginx.virtualHosts."matrix.${cfg.domain}" = {
      locations."/_matrix" = {
        proxyPass = "http://[::1]:6167";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 100M;";
      };
      locations."= /.well-known/matrix/server".extraConfig = ''
        return 200 '{"m.server":"matrix.${cfg.domain}:443"}';
        add_header Content-Type application/json;
      '';
      locations."= /.well-known/matrix/client".extraConfig = ''
        return 200 '{"m.homeserver":{"base_url":"https://matrix.${cfg.domain}"}}';
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
    };
  };
}
