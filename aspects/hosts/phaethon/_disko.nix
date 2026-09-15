{ inputs, lib, ... }:
let
  devices = import ./_devices.nix;

  fileSystems = (inputs.disko.lib.config { disko.devices = devices; }).fileSystems;
in
{
  boot.zfs.importPools = [ "rpool" ];

  fileSystems = lib.mkMerge [
    fileSystems
    {
      "/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "mode=1777"
        ];
      };
    }
  ];
}
