{ config, ... }:
{
  hosts.phaethon = {
    hostId = "0762b962";
    description = "finix server with ZFS storage and docker, part of the finix test matrix";
    classes = [ "finix" ];
    disko.devices = import ./_devices.nix;
    machineModules = [
      ./_hardware.nix
      ./_boot.nix
      ./_disko.nix
    ];
    system = "x86_64-linux";
    includes = with config.aspectLib.aspectNames; [
      bundle.base
      server.sshd
      finix.zfs
      finix.docker

      core.finitV5
      finix.doas
      finix.deviceManagers.gardendevd
      finix.network.dhcpcd
      finix.coreutils.gnu
      users.phaethon
    ];

    finix =
      {
        pkgs,
        lib,
        ...
      }:
      {
        boot.kernelPackages = pkgs.linuxPackages_6_12;

        programs.resolvconf.enable = true;

        users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      };
  };
}
