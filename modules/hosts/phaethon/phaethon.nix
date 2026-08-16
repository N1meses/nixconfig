{ config, ... }:
{
  registry.hosts.phaethon = {
    machineModules = [
      ./_hardware.nix
      ./_boot.nix
      ./_disko.nix
    ];
    users = with config.registry.userNames; [ phaethon ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    hostId = "0762b962";
    aspects = with config.aspectLib.names; [
      bundle.base
      server.sshd
      finix.zfs
      finix.docker

      core.finitV5
      finix.doas
      finix.devGardendevd
      finix.netDhcpcd
      finix.coreutilsGnu
    ];

    finixModule =
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

  diskoConfigurations.phaethon.disko.devices = import ./_devices.nix;
}
