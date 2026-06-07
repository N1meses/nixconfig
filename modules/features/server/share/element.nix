{...}: {
  flake.modules.nixos.element = {
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

          # Skip the login page and go straight to Authentik
          sso_redirect_options.immediate = true;

          # Disable email/phone login (you only use OIDC)
          disable_3pid_login = true;

          # Disable Element's integration manager (privacy)
          integrations_ui_url = "";
          integrations_rest_url = "";
          integrations_widgets_urls = [];

          # Disable bug reporting (privacy)
          bug_report_endpoint_url = "";

          # Show experimental features in settings
          show_labs_settings = true;
        };
      };
      locations."/".extraConfig = "try_files $uri $uri/ /index.html;";
    };
  };
}
