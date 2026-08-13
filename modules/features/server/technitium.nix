_: {
  aspects.technitium.description = "Technitium DNS server.";
  aspects.technitium.nixos = {
    services.technitium-dns-server = {
      enable = true;
      openFirewall = false;
    };

    networking.firewall.allowedUDPPorts = [ 53 ];
    networking.firewall.allowedTCPPorts = [ 53 ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5380 ];
  };
}
