{config, ...}: {
    aspects.airvpn.nixos = {config, ...}: {
      sops.secrets.airvpn-wg-conf-system = {};

      networking.wg-quick.interfaces.airvpn = {
        configFile = config.sops.secrets.airvpn-wg-conf-system.path;
      };

      networking.firewall.trustedInterfaces = ["airvpn"];

      services.resolved.enable = true;

      systemd.services.tailscaled.after = ["wg-quick-airvpn.service"];
    };
    aspects.airvpn.includes = with config.aspectLib.names; [sops];
}
