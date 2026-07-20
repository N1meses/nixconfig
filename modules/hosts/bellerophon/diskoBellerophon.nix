{ inputs, ... }:
let
  devices = {
    disk.bellerophon = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "f2fs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  fileSystems =
    (inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        { disko.devices = devices; }
      ];
    }).config.disko.devices._config.fileSystems;
in
{
  aspects.diskoBellerophon.finix =
    { lib, ... }:
    {
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
          # If /boot fails to mount on first finix boot (mountpoint missing on a fresh
          # root), add `"/boot".options = [ "X-mount.mkdir" ];` — cf. diskoIcarus.
        }
      ];
    };

  diskoConfigurations.bellerophon.disko.devices = devices;
}
