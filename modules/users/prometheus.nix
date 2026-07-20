{ config, lib, ... }:
{
  registry.users.prometheus = {
    extraGroups = [ ];
    keys = map builtins.readFile (lib.filesystem.listFilesRecursive ../features/base/super/keys);
    aspects = with config.aspectLib.names; [
      workstation
      hardwarePrometheus
      cachyosKernel
      hyprland
      gaming
      performance
      virtualisation
      c
      python
      rust
      markdown
      cli
      build
      direnv
    ];
  };
}
