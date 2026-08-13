{ inputs, lib, ... }:
let
  luksDevice = "/dev/disk/by-partlabel/disk-main-luks";

  devices = import ./_devices.nix;

  diskoConfig =
    (inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        { disko.devices = devices; }
      ];
    }).config.disko.devices._config;
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
