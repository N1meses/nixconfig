{...}: {
  flake.modules.nixos.croc = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server = {
      croc.enable = lib.mkEnableOption "Croc relay server";
    };

    config = lib.mkIf cfg.croc.enable {
      systemd.services.croc-relay = {
        description = "Croc relay server";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

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
