{...}: {
  flake.modules.nixos.tailscale = {...}: {
    services.tailscale.enable = true;
    services.tailscale.permitCertUid = "root";
    networking.firewall.trustedInterfaces = ["tailscale0"];
  };
}
