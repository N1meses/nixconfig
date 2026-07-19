let
  parentHost = "athena";
  parentDest = "100.75.163.80:19999";
in
{ config, ... }: {
  aspects.monitoring.nixos =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      isParent = config.networking.hostName == parentHost;
    in
    {
      services.netdata.enable = true;
      services.netdata.package = pkgs.netdata.override { withCloudUi = true; };
      services.netdata.config.plugins."scripts.d" = "no";
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 19999 ];

      services.netdata.config.db = lib.mkIf isParent {
        "mode" = "dbengine";
        "storage tiers" = "1";
        "dbengine tier 0 retention size" = "512MiB";
      };

      sops.secrets."netdata-stream-key" = { };
      sops.templates."netdata-stream.conf" = {
        owner = "netdata";
        content =
          if isParent then
            ''
              [${config.sops.placeholder."netdata-stream-key"}]
                  enabled = yes
                  allow from = *
                  default memory mode = dbengine
            ''
          else
            ''
              [stream]
                  enabled = yes
                  destination = ${parentDest}
                  api key = ${config.sops.placeholder."netdata-stream-key"}
            '';
      };
      services.netdata.configDir."stream.conf" = config.sops.templates."netdata-stream.conf".path;
    };
  aspects.monitoring.includes = with config.aspectLib.names; [ sops ];
}
