{ config, lib, ... }: let
  flakeConfig = config;
in {
  flake.modules.nixos.users = { config, lib, ... }: {
    imports = [ flakeConfig.flake.modules.nixos.overlays ];
    users.users = let
      hostname = config.networking.hostName;
      host = flakeConfig.registry.hosts.${hostname} or null;
    in lib.mkIf (host != null) {
      ${host.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ] ++ host.extraGroups;
      };
    };
  };
}
