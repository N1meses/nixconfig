{ config, ... }: {
  aspects.server.vpn.airvpn = {
    description = "AirVPN wireguard tunnel with a sops-held config.";
    includes = with config.aspectLib.names; [ core.sops ];
    nixos = { config, ... }: {
      sops.secrets.airvpn-wg-conf-system = { };

      networking.wg-quick.interfaces.airvpn = {
        configFile = config.sops.secrets.airvpn-wg-conf-system.path;
      };

      networking.firewall.trustedInterfaces = [ "airvpn" ];

      services.resolved.enable = true;

      systemd.services.tailscaled.after = [ "wg-quick-airvpn.service" ];
    };
  };
}
