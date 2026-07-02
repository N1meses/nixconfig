_: {
  flake.modules.nixos.monitoring = {pkgs, ...}: {
    services.netdata.enable = true;
    services.netdata.package = pkgs.netdata.override {withCloudUi = true;};
    services.netdata.config.plugins."scripts.d" = "no";
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [19999];
  };
}
