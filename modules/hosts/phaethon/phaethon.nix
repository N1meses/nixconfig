{ config, ... }:
{
  registry.hosts.phaethon = {
    users = with config.registry.userNames; [ phaethon ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    hostId = "0762b962";
    aspects = with config.aspectLib.names; [
      base
      sshd
      hardwarePhaethon
      diskoPhaethon
      zfs
      docker

      devGardendevd
      netDhcpcd
      coreutilsGnu
    ];

    finixModule =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        programs.resolvconf.enable = true;

        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

        finit.tasks.loadkmap = {
          description = "load console keymap (finix console.nix has no gardendevd path)";
          command = "${pkgs.execline}/bin/redirfd -r 0 ${config.hardware.console.binaryKeyMap} ${pkgs.busybox}/bin/loadkmap";
          conditions = "service/syslogd/ready";
        };

        boot.kernelPackages = pkgs.linuxPackages_6_12;

        users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      };
  };

  fleet.phaethon.home.ssh.matchBlocks.phaethon = {
    hostname = "TODO-tailscale-ip";
    user = "phaethon";
  };
}
