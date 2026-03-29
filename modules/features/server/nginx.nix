{...}: {
  flake.modules.nixos.nginx = {lib, ...}: {
    options.features.server.domain = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    config = {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80];

      services.fail2ban.jails = {
        nginx-http-auth.settings = {
          enabled = true;
          port = "http,https";
          filter = "nginx-http-auth";
          maxretry = 5;
        };
        nginx-botsearch.settings = {
          enabled = true;
          port = "http,https";
          filter = "nginx-botsearch";
          maxretry = 2;
        };
      };
    };
  };
}
