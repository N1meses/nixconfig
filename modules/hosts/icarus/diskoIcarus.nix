{inputs, ...}: let
  devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["mode=0755" "size=25%"];
    };
    disk.icarus = {
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
              mountOptions = ["umask=0077"];
            };
          };
          nix = {
            size = "60G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
          persist = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
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
        {disko.devices = devices;}
      ];
    })
    .config
    .disko
    .devices
    ._config
    .fileSystems;
in {
  flake.modules.finix.diskoIcarus = {lib, ...}: {
    fileSystems = lib.mkMerge [
      fileSystems
      {
        "/persist".neededForBoot = true;
        "/tmp" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = ["nosuid" "nodev" "mode=1777"];
        };
        "/boot" = {
          device = lib.mkForce "/dev/nvme0n1p1";
          noCheck = true;
        };
      }
    ];
  };

  flake.diskoConfigurations.icarus.disko.devices = devices;
}
