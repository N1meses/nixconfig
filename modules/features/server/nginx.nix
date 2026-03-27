{lib, ...}: {
  options.features.server.domain = lib.mkOption {
    type = lib.types.str;
    default = "";
  };

  config = {
    flake.modules.nixos.nginx = {...}: {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80];
    };
  };
}
