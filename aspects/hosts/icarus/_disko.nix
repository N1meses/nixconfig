{ inputs, lib, ... }:
let
  devices = import ./_devices.nix;

  fileSystems = (inputs.disko.lib.config { disko.devices = devices; }).fileSystems;
in
{
  fileSystems = lib.mkMerge [
    fileSystems
    {
      "/persist".neededForBoot = true;
      "/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "mode=1777"
        ];
      };
      "/boot" = {
        device = lib.mkForce "/dev/nvme0n1p1";
        noCheck = true;
        options = [ "X-mount.mkdir" ];
      };
    }
  ];
}
