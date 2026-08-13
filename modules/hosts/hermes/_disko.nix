{ lib, ... }: {
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = [
      "defaults"
      "size=50%"
      "mode=755"
    ];
  };

  fileSystems."/persist".neededForBoot = true;

  disko.devices.disk.main = {
    device = lib.mkDefault "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        nix = {
          size = "40G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
          };
        };
        persist = {
          size = "160G";
          content = {
            type = "luks";
            name = "persist";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
        };
        data = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "exfat";
            mountpoint = null;
          };
        };
      };
    };
  };
}
