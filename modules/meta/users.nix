{ config, lib, ... }: let
  flakeConfig = config;
in {
  flake.modules.nixos.users = { config, lib, pkgs, ... }: {
    imports = [ flakeConfig.flake.modules.nixos.overlays ];
    users.users = let
      hostname = config.networking.hostName;
      host = flakeConfig.registry.hosts.${hostname} or null;
    in lib.mkIf (host != null) {
      ${host.username} = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "networkmanager" ] ++ host.extraGroups;
      };
    };
  };
}
