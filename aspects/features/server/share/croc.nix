_: {
  aspects.server.share.croc = {
    description = "croc file-transfer relay on the tailnet.";
    nixos = { pkgs, ... }: {
      systemd.services.croc-relay = {
        description = "Croc relay server";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.croc}/bin/croc relay";
          Restart = "on-failure";
          DynamicUser = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
        };
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
        9009
        9010
        9011
        9012
        9013
      ];
    };
  };
}
