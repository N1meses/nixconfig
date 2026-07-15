{config, ...}: {
    aspects.element.nixos = {
      config,
      pkgs,
      ...
    }: let
      cfg = config.features.server;
    in {
      services.nginx.virtualHosts."element.${cfg.domain}" = {
        root = pkgs.element-web.override {
          conf = {
            default_server_config."m.homeserver" = {
              base_url = "https://matrix.${cfg.domain}";
              server_name = "matrix.${cfg.domain}";
            };
            disable_guests = true;
            default_theme = "dark";

            sso_redirect_options.immediate = true;

            disable_3pid_login = true;

            integrations_ui_url = "";
            integrations_rest_url = "";
            integrations_widgets_urls = [];

            bug_report_endpoint_url = "";

            show_labs_settings = true;
          };
        };
        locations."/".extraConfig = "try_files $uri $uri/ /index.html;";
      };
    };
    aspects.element.includes = with config.aspectLib.names; [nginx];
}
