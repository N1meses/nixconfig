{ config, ... }:
{
  registry.hosts.phaethon = {
    machineModules = [
      ./_hardware.nix
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
        programs.resolvconf.enable = true;

        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

        boot.kernelPackages = pkgs.linuxPackages_6_12;

        users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      };
  };

  fleet.phaethon.home.ssh.matchBlocks.phaethon = {
    hostname = "TODO-tailscale-ip";
    user = "phaethon";
  };

  diskoConfigurations.phaethon.disko.devices = import ./_devices.nix;
}
