{ config, lib, ... }:
{
  registry.users.nimeses = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      workstation
      diskoNimeses
      hardwareNimeses
      cachyosKernel
      laptop
      airvpn
      python
      c
      rust
      markdown
      direnv
      cli
      music
      sops
    ];
  };
}
