{inputs, ...}: {
  flake.modules = {
    nixos.tailscale = _: {
      services.tailscale.enable = true;
      services.tailscale.permitCertUid = "root";
      networking.firewall.trustedInterfaces = ["tailscale0"];
    };
    finix.tailscale = {modules, ...}: {
      imports = [
        inputs.finix-community-modules.nixosModules.tailscale
        modules.dhcpcd
      ];
      services.tailscale.enable = true;
    };
  };
}
