_: {
  aspects.diskoAtlas.nixos =
    { config, ... }:
    let
      mkTankDisk = id: {
        type = "disk";
        device = "/dev/disk/by-id/${id}";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
    in
    {
      disko.devices = {
        disk = {
          rpool = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENJ0Y726586K";
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
                swap = {
                  size = "32G";
                  content = {
                    type = "swap";
                    randomEncryption = true;
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

          tank0 = mkTankDisk "ata-ST4000VN006-3CW104_ZW647N79";
          tank1 = mkTankDisk "ata-ST4000VN006-3CW104_WW608HJX";
          tank2 = mkTankDisk "ata-ST4000VN006-3CW104_WW6AB5WN";
          tank3 = mkTankDisk "ata-ST4000VN006-3CW104_ZW64A7VV";
        };

        zpool = {
          rpool = {
            type = "zpool";
            mode = "";
            options.cachefile = "none";
            rootFsOptions = {
              compression = "zstd";
              acltype = "posixacl";
              xattr = "sa";
              atime = "off";
              "com.sun:auto-snapshot" = "false";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
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
              postgres = {
                type = "zfs_fs";
                mountpoint = "/var/lib/postgresql";
                options.recordsize = "16k";
              };
            };
          };

          tank = {
            type = "zpool";
            mode = "raidz2";
            options.cachefile = "none";
            rootFsOptions = {
              compression = "zstd";
              acltype = "posixacl";
              xattr = "sa";
              atime = "off";
              "com.sun:auto-snapshot" = "false";
              encryption = "aes-256-gcm";
              keyformat = "raw";
              keylocation = "file:///etc/zfs/tank.key";
              mountpoint = "none";
            };
            datasets = {
              media = {
                type = "zfs_fs";
                options = {
                  mountpoint = "/media";
                  recordsize = "1M";
                };
              };
              ocis = {
                type = "zfs_fs";
                options.mountpoint = "/var/lib/ocis";
              };
              downloads = {
                type = "zfs_fs";
                options.mountpoint = "/downloads";
              };
              backup = {
                type = "zfs_fs";
                options.mountpoint = "/backup";
              };
            };
          };
        };
      };

      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = false;
      boot.zfs.devNodes = "/dev/disk/by-id";
      boot.zfs.extraPools = [ "tank" ];
      boot.zfs.requestEncryptionCredentials = [ "rpool" ];
      boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

      services.zfs.trim.enable = true;
      services.zfs.autoScrub.enable = true;

      systemd.services.zfs-load-key-tank = {
        description = "Load ZFS key for tank from rpool keyfile";
        after = [ "zfs-import-tank.service" ];
        requiredBy = [ "zfs-mount.service" ];
        before = [ "zfs-mount.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${config.boot.zfs.package}/bin/zfs load-key -a";
        };
      };

      services.sanoid = {
        enable = true;
        datasets = {
          "tank/ocis" = {
            hourly = 24;
            daily = 30;
            monthly = 6;
            autosnap = true;
            autoprune = true;
          };
          "tank/media" = {
            daily = 7;
            weekly = 4;
            autosnap = true;
            autoprune = true;
          };
          "tank/downloads" = {
            autosnap = false;
            autoprune = false;
          };
          "rpool/postgres" = {
            hourly = 24;
            daily = 14;
            autosnap = true;
            autoprune = true;
          };
        };
      };
    };
}
