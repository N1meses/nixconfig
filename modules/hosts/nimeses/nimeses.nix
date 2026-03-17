{ config, lib, pkgs, ... }: {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };
  configurations.nixos.nimeses = {
    module = {
      imports = with config.flake.modules.nixos; [
        users
      ];
    };
    hardware-configuration = ./hardware-configuration.nix;
  };
  configurations.home-manager.nimeses.module = {
    home.packages = with pkgs; [ btop ];
  };
}
