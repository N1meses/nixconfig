{...}: {
  flake.modules.nixos.tailscale = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.server.tailscale;
  in {
    options.features.server.tailscale.enable = lib.mkEnableOption "Tailscale";

    config = lib.mkIf cfg.enable {
      services.tailscale.enable = true;
      networking.firewall.trustedInterfaces = ["tailscale0"];
    };
  };
}
