{ inputs, ... }:
let
  devices = {
    disk.main = {
      device = "/dev/sda";
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
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";
      options.ashift = "12";
      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
        mountpoint = "none";
      };
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        docker = {
          type = "zfs_fs";
          mountpoint = "/var/lib/docker";
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
  aspects.diskoPhaethon.finix =
    { lib, ... }:
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
    };

  diskoConfigurations.phaethon.disko.devices = devices;
}
