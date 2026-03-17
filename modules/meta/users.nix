{ config, lib, ... }: {
  flake.modules.nixos.users = {
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
