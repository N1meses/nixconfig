{ config, lib, ... }:
{
  registry.users.icarus = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      hardwareIcarus
      diskoIcarus
      sshd
      base
      niri
      ly
      users
      session
      nix
      desktop
      ssh
      foot
      laptop
      persistence
      zed
    ];
  };
}
