{inputs, ...}: {
  aspects.tailscale = {
    nixos = _: {
      services.tailscale.enable = true;
      services.tailscale.permitCertUid = "root";
      networking.firewall.trustedInterfaces = ["tailscale0"];
    };
    finix = {...}: {
      imports = [
        inputs.community-modules.nixosModules.tailscale
      ];
      services.tailscale.enable = true;
    };
  };
}
