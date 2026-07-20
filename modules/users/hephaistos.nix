{ config, lib, ... }:
{
  registry.users.hephaistos = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      server
      hardwareHephaistos
      vaultwarden
      croc
      nix
      fastfetch
    ];
  };
}
