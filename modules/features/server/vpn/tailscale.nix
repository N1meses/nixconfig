{ inputs, ... }: {
  aspects.server.vpn.tailscale = {
    nixos = _: {
      services.tailscale.enable = true;
      services.tailscale.permitCertUid = "root";
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
    finix = { lib, ... }: {
      imports = [
        inputs.community-modules.nixosModules.tailscale
      ];
      services.tailscale.enable = true;
      finit.services.tailscaled.conditions = lib.mkForce [ "service/syslogd/ready" ];
    };
    description = "Tailscale mesh VPN, trusted in the firewall.";
  };
}
