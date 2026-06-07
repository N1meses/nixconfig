{...}: {
  flake.modules.nixos.monitoring = {
    services.netdata.enable = true;

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [19999];
  };
}
