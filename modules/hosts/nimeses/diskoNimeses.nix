{ inputs, ... }:
let
  luksDevice = "/dev/disk/by-partlabel/disk-main-luks";

  devices = {
    disk.main = {
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
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

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
  aspects.diskoNimeses.finix =
    { lib, ... }:
    {
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
    };

  diskoConfigurations.nimeses.disko.devices = devices;
}
