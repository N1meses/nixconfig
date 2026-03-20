{
  config,
  ...
}: {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      users
      core
      hardware-nimeses
      base
      shell
    ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      shell
      core
    ];

    home.packages = with pkgs; [ btop ];
  };
}
