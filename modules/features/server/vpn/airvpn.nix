_: {
  flake.modules.nixos.airvpn = {config, ...}: {
    sops.secrets.airvpn-wg-conf-system = {};

    networking.wg-quick.interfaces.airvpn = {
      configFile = config.sops.secrets.airvpn-wg-conf-system.path;
    };

    networking.firewall.trustedInterfaces = ["airvpn"];

    services.resolved.enable = true;

    systemd.services.tailscaled.after = ["wg-quick-airvpn.service"];
  };
}
