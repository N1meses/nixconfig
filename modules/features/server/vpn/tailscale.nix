_: {
  flake.modules.nixos.tailscale = _: {
    services.tailscale.enable = true;
    services.tailscale.permitCertUid = "root";
    networking.firewall.trustedInterfaces = ["tailscale0"];
  };
}
