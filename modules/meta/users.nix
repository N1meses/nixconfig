{ config, lib, ... }: {
  flake.modules.nixos.users = {
    imports = [ config.flake.modules.nixos.overlays ];
    users.users = lib.mkMerge (
      lib.mapAttrsToList (hostname: host: {
        ${host.username} = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" ];
        };
      }) config.registry.hosts
    );
  };
}
