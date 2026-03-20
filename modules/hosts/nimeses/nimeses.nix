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
    ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.home-manager.nimeses.module = {pkgs, ...}: {
    home.packages = with pkgs; [ btop ];
  };
}
