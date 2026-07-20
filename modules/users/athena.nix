{ config, lib, ... }:
{
  registry.users.athena = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      server
      hardwareAthena
      monitoring
      vaultwarden
      croc
      technitium
      fastfetch
    ];
  };
}
