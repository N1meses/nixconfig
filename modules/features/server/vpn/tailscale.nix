{inputs, ...}: {
  flake.modules = {
    nixos.tailscale = _: {
      services.tailscale.enable = true;
      services.tailscale.permitCertUid = "root";
      networking.firewall.trustedInterfaces = ["tailscale0"];
    };
    finix.tailscale = {...}: {
      imports = [
        inputs.finix-community-modules.nixosModules.tailscale
      ];
      services.tailscale.enable = true;
    };
  };
}
