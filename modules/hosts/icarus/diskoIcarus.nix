{inputs, ...}: let
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
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
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
        {disko.devices = devices;}
      ];
    })
    .config
    .disko
    .devices
    ._config
    .fileSystems;
in {
  flake.modules.finix.diskoIcarus = {...}: {
    inherit fileSystems;
  };

  flake.diskoConfigurations.icarus.disko.devices = devices;
}
