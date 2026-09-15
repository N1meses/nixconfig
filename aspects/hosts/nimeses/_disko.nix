{ inputs, lib, ... }:
let
  luksDevice = "/dev/disk/by-partlabel/disk-main-luks";

  devices = import ./_devices.nix;

  diskoConfig = inputs.disko.lib.config { disko.devices = devices; };
in
{
  boot.initrd.supportedFilesystems.luks.enable = true;
  boot.supportedFilesystems.luks.enable = true;

  swapDevices = diskoConfig.swapDevices;

  fileSystems = lib.mkMerge [
    diskoConfig.fileSystems
    {
      crypted = {
        device = luksDevice;
        fsType = "luks";
        options = [ "--allow-discards" ];
      };
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
