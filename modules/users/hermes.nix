{ config, lib, ... }:
{
  registry.users.hermes = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      base
      hardwareHermes
      diskoHermes
      impermanenceHermes
      cachyosKernel
      rescue
      services
      niri
      noctalia
      ly
      nh
      foot
      yazi
      browser
    ];
  };
}
