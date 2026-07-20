{ config, lib, ... }:
{
  registry.users.atlas = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      server
      hardwareAtlas
      diskoAtlas
      monitoring
      forgejo
      binaryCache
      forgejoRunner
      jellyfin
      authentik
      cloudflared
      matrix
      element
      nixarr
      ocis
      fastfetch
    ];
  };
}
